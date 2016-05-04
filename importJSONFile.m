function data = importJSONFile(fileIndex,locationID,myFiles)
  jsonFile = myFiles(fileIndex).name;
  filePath = strcat('./exportParse/exportLocation_', locationID,'/',jsonFile);
  data = loadjson(filePath);
  %data = struct;
end
