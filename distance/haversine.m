function d = haversine(x, y)
    numQueries = size(y, 1);
    
    arclen = distance(repmat(x, numQueries, 1), y);
    d = deg2km(arclen)/1000;
end