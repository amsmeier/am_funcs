%%% look for string_to_find in every cell of table_in and replace with new_string
% intended to replace "F:" in every path of analysis_master.xlxs with the actual data path of the computer

function table_out = replace_table_strings(table_in, string_to_find, new_string)

table_out = table_in;

for k = 1:width(table_out)
    var = table_out.(k);

    % Process cell arrays
    if iscell(var)

        % Replace in character vectors
        char_mask = cellfun(@ischar, var);
        var(char_mask) = cellfun( ...
            @(x) strrep(x, string_to_find, new_string), ...
            var(char_mask), ...
            'UniformOutput', false);

        % Replace in string scalars
        string_mask = cellfun(@isstring, var);
        var(string_mask) = cellfun( ...
            @(x) strrep(x, string_to_find, new_string), ...
            var(string_mask), ...
            'UniformOutput', false);

        table_out.(k) = var;
    end
end
