clear all
close all
% addpath('./jsonlab-1.2/jsonlab');


startDate = '2015-9-01'; % yyyy-MM-dd
endDate = '2015-9-31'; % yyyy-MM-dd
type = 'CME'; %all, FLR, SEP, CME, IPS, MPC, GST, RBE, report
Donki = sprintf('http://kauai.ccmc.gsfc.nasa.gov/DONKI/WS/get/notifications?startDate=%s&endDate=%s&type=%s',startDate,endDate,type);

% json = loadjson(urlread(Donki));
json = parse_json(urlread(Donki));
data = cell2mat(json);

datalength = length(data);

tmp = cell(size(data));
[data(:).Summary] = deal(tmp{:});
[data(:).Update] = deal(tmp{:});
[data(:).Several] = deal(tmp{:});
[data(:).Beta] = deal(tmp{:});
[data(:).Other] = deal(tmp{:});
[data(:).Links] = deal(tmp{:});
[data(:).Notes] = deal(tmp{:});
[data(:).ActivityID] = deal(tmp{:});
[data(:).CMEType] = deal(tmp{:});

for iteration = 1:length(data)
    %
    Body = data(iteration).messageBody;

    [sum_start sum_end] = regexp(Body,'## Summary:');
% [sum_start sum_end] = regexp(Body,'Links')
    [notes_start notes_end] = regexp(Body,'## Notes:');

    summary_full = Body(sum_end+1:notes_start-1);
    links_start = regexp(summary_full,'Links');
    links = summary_full(links_start-1:end);
    notes_full = Body(notes_end+1:end);
    
    data(iteration).Summary = summary_full;
    data(iteration).Links = links;
    data(iteration).Notes = notes_full;
    
    if regexp(summary_full,'Activity ID') >0
%         if regexp(summary_full,'Multiple') == 0
%         activity_id = regexp(summary_full,'Activity ID');
%         nwline = regexp(summary_full,'\n');

%         for ii = 1:length(activity_id)
%             nwline = nwline(find(nwline > activity_id(ii)));
%             nwline = nwline(1);
%         end
        [activity_id_start activity_id_end] = regexp(summary_full,'Activity ID: ...........................\n');
        data(iteration).ActivityID = summary_full(activity_id_start:activity_id_end);
        data(iteration).Other = summary_full(activity_id_end+1:links_start-1);
    end
        %     summary = summary_full;
    summary = summary_full(1:links_start-1);
    summary = summary(1:activity_id_start-1);
%     summary = summary_full(1:activity_id_start-1);
%     summary = summary_full(1:regexp(summary_full,'Activity ID')-1);
    
    if strcmp(data(iteration).messageType,'CME') == 1
        if regexp(summary_full,'Several') >0
            data(iteration).Several = summary;
            continue
        end

        if regexp(summary_full,'Multiple') >0
            data(iteration).Several = summary;
            continue
        end
        
        if regexp(summary_full,'BETA')>0
            data(iteration).Beta = summary_full;
            continue
        end
        
        doubleenter = regexp(summary,'\n\n');
%         final_line = summary(doubleenter(end-1):doubleenter(end));
        summary = summary(1:doubleenter(end-1)-1);

        if regexp(summary,'Update') >0
            newline = regexp(summary,'\n');
            data(iteration).Update = summary(regexp(summary,'Update'):newline(3));
        end
        
% summary = regexprep(summary,'\n',' ');
        summary = regexprep(summary,'lon\./lat\.','lon/lat');
        [TZs TZe] = regexp(summary,'T..:..Z');

        for ii = 1:length(TZe)
            tmp_replace = regexprep(summary(TZs(ii):TZe(ii)),':',';');
            summary = regexprep(summary,'T..:..Z',tmp_replace);
        end
        
%         if regexp
        
        sum_colon = regexp(summary,':');
%         sum_colon = sum_colon(1:end);
        sum_dot = regexp(summary,'\.');
%         sum_dot(end+1) = length(summary);
        if regexp(summary,'Update') >0
            summary = summary(newline(3):end);
            summary = regexprep(summary,'type):','type).');
            sum_colon = regexp(summary,':');
%             sum_colon = sum_colon(1:end-2)
            sum_dot = regexp(summary,'\.');
%             sum_dot(end+1) = length(summary)
        end
%         if regexp(summary,'type):') >0
            
% names = zeros(length(sum_colon)-2,1); info = zeros(length(sum_colon)-2,1);
        CME_type = summary(1:sum_dot(1));
        data(iteration).CMEType = CME_type;
        
        for ii = 1:length(sum_colon)
            names{ii} = {summary(sum_dot(ii)+1:sum_colon(ii))};
            info{ii} = {summary(sum_colon(ii)+1:sum_dot(ii+1))};
        end
% sum_nonew(sum_dot(1)+1:sum_colon(1)) = sum_nonew(sum_colon(1)+1:sum_dot(2))
%         sum = horzcat(names',info');

%         tmp = cell(size(data));
        for ii = 1:length(names)
            tmpname = names{ii}{1};
            tmpname = regexprep(tmpname,'[\n:/-()]','');
            tmpname = regexprep(tmpname,' ','');
%     name = regexprep(name,':','');
%     name = regexprep(name,'-','');
            if isfield(data, tmpname) == 0
                [data(:).(tmpname)] = deal(tmp{:});
%             elseif isfield(data, tmpname) == 1
            end
            data(iteration).(tmpname) = info{ii}{1};
        end
    end
end
%%
% end

% %%
%         elseif regexp(summary_full,'Multiple') >0
%             continue
%             [activity_id_start activity_id_end] = regexp(summary_full,'Activity ID: ...........................\n');
%             second_length = length(activity_id_start);
%             
%             for second_iteration = 1:second_length
%                 [activity_id_start activity_id_end] = regexp(summary_full,'Activity ID: ...........................\n');
% %                 data(length(data)+second_iteration = [];
%                 data(datalength+second_iteration).ActivityID = summary_full(activity_id_start(second_iteration):activity_id_end(second_iteration));
%                 data(datalength+second_iteration).Other = summary_full(activity_id_end(length(activity_id_start))+1:links_start-1);
%                 data(datalength+second_iteration).Links = links;
%                 data(datalength+second_iteration).Notes = notes_full;
% %         nwline = regexp(summary_full,'\n');
% %         for ii = 1:length(activity_id)
% %             nwline = nwline(find(nwline > activity_id(ii)));
% %             nwline = nwline(1);
% %         end
%                 summary = summary_full(1:activity_id_start(end)-1);
%                 summary = regexprep(summary,'lon\./lat\.','lon/lat');
%                 [TZs TZe] = regexp(summary,'T..:..Z');
% 
%                 for ii = 1:length(TZe)
%                     tmp_replace = regexprep(summary(TZs(ii):TZe(ii)),':',';');
%                     summary = regexprep(summary,'T..:..Z',tmp_replace)
%                 end
%                 [multi_start multi_end] = regexp(summary,'Multiple CMEs have been detected as follows:');
%                 summary_event = summary(multi_end+1:end)
%                 
%                 [activity_id_start activity_id_end] = regexp(summary_event,'Activity ID: ...........................\n');
% %                 summary = {
% %                 if length(activity_id_end) >= 2
% %                     for ii = 1:length(activity_id_start)
% %                         tmpevent = summary(activity_id_end(ii)+1:activity_id_start(ii));
% %                         data(datalength+second_iteration).Summary = tmpevent;
% %                     end
% %                 elseif length(activity_id_end) == 1
% %                     firstevent = summary(1:activity_id_start-1);
% %                     data(datalength+second_iteration).Summary = firstevent;
% %                     secondevent = summary(activity_id_end:end);
% %                     datalength = length(data);
% %                     data(datalength+second_iteration).Summary = secondevent;
% %                     break
%                 end
%                 end
%                 end
%             end
%         
% %     end
%     
%     
% % %     summary = summary_full;
% %     summary = summary_full(1:links_start-1);
% %     summary = summary_full(1:regexp(summary_full,'Activity ID')-1);
% %     
% %     if strcmp(data(iteration).messageType,'CME') == 1
% %         if regexp(summary_full,'Several') >0
% %             data(iteration).Several = summary;
% %             continue
% %         end
% %         doubleenter = regexp(summary,'\n\n');
% % %         final_line = summary(doubleenter(end-1):doubleenter(end));
% %         summary = summary(1:doubleenter(end-1)-1);
% %         if regexp(summary,'BETA')>0
% %             data(iteration).Beta = summary_full;
% %             continue
% %         end
% %         if regexp(summary,'Update') >0
% %             newline = regexp(summary,'\n');
% %             data(iteration).Update = summary(regexp(summary,'Update'):newline(3));
% %         end
% %         
% % % summary = regexprep(summary,'\n',' ');
% %         summary = regexprep(summary,'lon\./lat\.','lon/lat');
% %         [TZs TZe] = regexp(summary,'T..:..Z');
% % 
% %         for ii = 1:length(TZe)
% %             tmp_replace = regexprep(summary(TZs(ii):TZe(ii)),':',';');
% %             summary = regexprep(summary,'T..:..Z',tmp_replace);
% %         end
% %         
% % %         if regexp
% %         
% %         sum_colon = regexp(summary,':');
% %         sum_colon = sum_colon(1:end);
% %         sum_dot = regexp(summary,'\.');
% % %         sum_dot(end+1) = length(summary);
% %         if regexp(summary,'Update') >0
% %             summary = summary(newline(3):end);
% %             summary = regexprep(summary,'type):','type).');
% %             sum_colon = regexp(summary,':');
% % %             sum_colon = sum_colon(1:end-2)
% %             sum_dot = regexp(summary,'\.');
% % %             sum_dot(end+1) = length(summary)
% %         end
% % %         if regexp(summary,'type):') >0
% %             
% % %         end
% %         
% % % names = zeros(length(sum_colon)-2,1); info = zeros(length(sum_colon)-2,1);
% %         CME_type = summary(1:sum_dot(1));
% %         data(iteration).CMEType = CME_type;
% %         
% %         for ii = 1:length(sum_colon)
% %             names{ii} = {summary(sum_dot(ii)+1:sum_colon(ii))};
% %             info{ii} = {summary(sum_colon(ii)+1:sum_dot(ii+1))};
% %         end
% % % sum_nonew(sum_dot(1)+1:sum_colon(1)) = sum_nonew(sum_colon(1)+1:sum_dot(2))
% % %         sum = horzcat(names',info');
% % 
% % %         tmp = cell(size(data));
% %         for ii = 1:length(names)
% %             tmpname = names{ii}{1};
% %             tmpname = regexprep(tmpname,'[\n:/-()]','');
% %             tmpname = regexprep(tmpname,' ','');
% % %     name = regexprep(name,':','');
% % %     name = regexprep(name,'-','');
% %             if isfield(data, tmpname) == 0
% %                 [data(:).(tmpname)] = deal(tmp{:});
% %             else
% %                 data(iteration).(tmpname) = info{ii}{1};
% %             end
% %         end
% %     end
% % 
