% This codes defines a function that uploads the .JSON data downloaded from the cloud into Matlab. 
% The "JSON.m" program uses this code to analyze the JSON file and change all the data into Matlab arrays. 

function data = importJSONFile(fileIndex,locationID,myFiles) 
  jsonFile = myFiles(fileIndex).name;
  filePath = strcat('../parseDownloader/exportParse/exportLocation_', locationID,'/',jsonFile);
  data = loadjson(filePath);
  %data = struct;
end
