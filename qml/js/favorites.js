/**********************************************************************
*
* This file is part of the JollaOpas, forked from Jopas originally
* forked from Meegopas.
* More information:
*
*   https://github.com/hsarkanen/JollaOpas
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Heikki Sarkanen <heikki.sarkanen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jani Mikkonen <jani.mikkonen@gmail.com>
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*
* All assets contained within this project are copyrighted by their
* respectful authors.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* See full license at http://www.gnu.org/licenses/gpl-3.0.html
*
**********************************************************************/

// Adapted from:http://www.developer.nokia.com/Community/Wiki/How-to_create_a_persistent_settings_database_in_Qt_Quick_%28QML%29

.import QtQuick.LocalStorage 2.0 as Sql

// First, let's create a short helper function to get the database connection
function getDatabase() {
     return Sql.LocalStorage.openDatabaseSync("JollaOpas", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase()
    var version = checkSchema(db)
    if (version.toString() === "0") {
        db.transaction(
            function(tx) {
                tx.executeSql('PRAGMA user_version;');
                // Create the settings table if it doesn't already exist
                // If the table exists, this is skipped
                // Type is just preparation for possibly different favorite types in the future
                tx.executeSql('CREATE TABLE IF NOT EXISTS favorites(coord TEXT UNIQUE, type TEXT NOT NULL, api TEXT NOT NULL, name TEXT NOT NULL);');
                // Favourite routes, fixed amount of 4 per City, in different table
                tx.executeSql('CREATE TABLE IF NOT EXISTS favoriteRoutes(routeIndex INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, api TEXT NOT NULL, fromCoord TEXT NOT NULL, fromName TEXT NOT NULL, toCoord TEXT NOT NULL, toName TEXT NOT NULL);');
                var rs = tx.executeSql("ALTER TABLE favorites ADD LocationType TEXT NOT NULL DEFAULT('address'),city TEXT NOT NULL DEFAULT('Old favorite: Update');");
                if (rs.rowsAffected >=0){
                    tx.executeSql('PRAGMA user_version = 1;');
                }
            });
    }

}

function checkSchema(db) {
    var r
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('PRAGMA user_version;');
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            // Type is just preparation for possibly different favorite types in the future
            r = rs.rows.item(0).user_version
        });
    return r
}


// This function checks if the favorite already exists
function favoritExists(coord) {
    var db = getDatabase();
    var res = null;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT 1 FROM favorites WHERE coord = ?', coord);
        res = rs.rows.length > 0 ? true : false
    });
  return res;
}

// This function is used to write a setting into the database
function addFavorite(name, coord, city, locationtype) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT coord,name FROM favorites WHERE coord = ?', coord);
                       if (rs.rows.length > 0) {
                           res = "Not exist"
                       }
                       else {
                           console.log(name, coord, city, locationtype)
                           rs = tx.executeSql('INSERT INTO favorites (coord,type,api,name,city,LocationType) VALUES (?,?,?,?,?,?);', [coord,'normal',appWindow.currentApi,name,city,locationtype]);
                           if (rs.rowsAffected > 0) {
                               res = "OK";
                           } else {
                               res = "Error";
                           }
                       }
                   });
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to write a setting into the database
function addFavoriteRoute(type, api, fromCoord, fromName, toCoord, toName, updatemodel) {
    var db = getDatabase();
    var res = "";
    var rs = {};
    db.transaction(function(tx) {
        if (type == 'cover') {
            // Replace the possibly existing cover favorite for this api
            rs = tx.executeSql('DELETE FROM favoriteRoutes WHERE type = ? AND api = ?;', [type,api]);
            rs = tx.executeSql('INSERT INTO favoriteRoutes (type,api, fromCoord,fromName,toCoord,toName) VALUES (?,?,?,?,?,?);', [type,api,fromCoord,fromName,toCoord,toName]);
            if (rs.rowsAffected === 1) {
                res = "OK";
            }
            else {
                res = "Error";
            }
        }
        else {
            rs = tx.executeSql('SELECT routeIndex FROM favoriteRoutes WHERE type = ? AND api = ?', [type,api]);
            // Check that there is still place for favoriteRoute (limited up to 4 per City)
            if (rs.rows.length >= 4) {
                res = "Error"
            }
            else {
                rs = tx.executeSql('INSERT INTO favoriteRoutes (type,api,fromCoord,fromName,toCoord,toName) VALUES (?,?,?,?,?,?);', [type,api,fromCoord,fromName,toCoord,toName]);
                if (rs.rowsAffected === 1) {
                    updatemodel.clear()
                    getFavoriteRoutes('normal',api,updatemodel)
                    res = "OK";
                } else {
                    res = "Error";
                }
            }
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to write a setting into the database
function updateFavorite(name, coord, updatemodel) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
                       var rs = tx.executeSql('SELECT coord,name FROM favorites WHERE coord = ?', coord);
                       if (rs.rows.length != 1) {
                           res = "Not exist"
                       }
                       else {
                           rs = tx.executeSql('UPDATE favorites SET name = ? WHERE coord = ?', [name,coord]);
                           if (rs.rowsAffected > 0) {
                               res = "OK";
                               updatemodel.clear()
                               getFavorites(updatemodel)
                           } else {
                               res = "Error";
                           }
                       }
                   });
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to write a setting into the database
function deleteFavorite(coord, updatemodel) {
   // setting: string representing the setting name (eg: “username”)
   // value: string representing the value of the setting (eg: “myUsername”)
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM favorites WHERE coord = ?;', coord);
              if (rs.rowsAffected > 0) {
                res = "OK";
                  updatemodel.clear()
                  getFavorites(updatemodel)
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to write a setting into the database
function deleteFavoriteRoute(routeIndex, api, updatemodel) {
   // setting: string representing the setting name (eg: “username”)
   // value: string representing the value of the setting (eg: “myUsername”)
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM favoriteRoutes WHERE routeIndex = ? AND api = ?;', [routeIndex,api]);
              if (rs.rowsAffected == 1) {
                res = "OK";
                  updatemodel.clear()
                  getFavoriteRoutes('normal',api,updatemodel)
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}

// This function is used to retrieve a setting from the database
function getFavorites(model) {
   var db = getDatabase();
   var res="";
   db.transaction(function(tx) {
     var rs = tx.executeSql('SELECT coord,name,city,LocationType FROM favorites WHERE api = ?', appWindow.currentApi);
     if (rs.rows.length > 0) {
         for(var i = 0; i < rs.rows.length; i++) {
             var output = {}
             output.name = rs.rows.item(i).name;
             output.coord = rs.rows.item(i).coord;
             output.type = "favorite"
             output.locationType = rs.rows.item(i).LocationType;
             output.city = rs.rows.item(i).city;
             model.append(output)
         }
     } else {
         res = "Unknown";
     }
  })
  // The function returns “Unknown” if the setting was not found in the database
  // For more advanced projects, this should probably be handled through error codes
  return res
}

// This function is used to retrieve a setting from the database
function getFavoriteRoutes(type, api, model) {
    var db = getDatabase();
    var res = "";
    var rs = {};
    db.transaction(function(tx) {
        if (type == 'cover') {
            rs = tx.executeSql('SELECT fromCoord,fromName,toCoord,toName FROM favoriteRoutes WHERE type = ? AND api = ?', [type,api]);
            if (rs.rows.length == 1) {
                model.modelFromCoord = rs.rows.item(0).fromCoord;
                model.modelFromName = rs.rows.item(0).fromName;
                model.modelToCoord = rs.rows.item(0).toCoord;
                model.modelToName = rs.rows.item(0).toName;
                model.modelType = "favoriteRoute"
            }
            else {
                res = "Unknown";
            }
        }
        else {
            rs = tx.executeSql('SELECT routeIndex,fromCoord,fromName,toCoord,toName FROM favoriteRoutes WHERE type = ? AND api = ?', [type,api]);
            if (rs.rows.length > 0) {
                for(var i = 0; i < rs.rows.length; i++) {
                    var output = {}
                    output.modelRouteIndex = rs.rows.item(i).routeIndex;
                    output.modelFromCoord = rs.rows.item(i).fromCoord;
                    output.modelFromName = rs.rows.item(i).fromName;
                    output.modelToCoord = rs.rows.item(i).toCoord;
                    output.modelToName = rs.rows.item(i).toName;
                    output.modelType = "favoriteRoute"
                    model.append(output)
                }
            } else {
                res = "Unknown";
            }
        }
    })
  // The function returns “Unknown” if the setting was not found in the database
  // For more advanced projects, this should probably be handled through error codes
  return res
}
