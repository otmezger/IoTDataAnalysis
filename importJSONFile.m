function data = importJSONFile(fileIndex,locationID,myFiles)
  jsonFile = myFiles(fileIndex).name;
  filePath = strcat('../parseDownloader/exportParse/exportLocation_', locationID,'/',jsonFile);
  data = loadjson(filePath);
  %data = struct;
end
