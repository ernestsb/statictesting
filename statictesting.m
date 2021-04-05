clear all ;close all;clc

% Written By Ernest Sebastian Constantine
% May 2019
%% Load the area data
cd 'C:\Users\Ernest\Desktop\THESIS\Tensile test'
[~,~,area] = xlsread('area_input_eff.xlsx'); % read area file - excel file containing specimen name and its area
%to convert numeric to string
for ii=1:size(area,1)
   if isnumeric(area{ii,1})
                area{ii,1} = num2str(area{ii,1});
   end
end

%% MAIN PROGRAM

file = 'DA_A2';                                          % >>>>>CHANGE THIS
path = 'C:\Users\Ernest\Desktop\THESIS\Tensile test\DA_A2\DAT'; % >>>>>THIS TOO
cd (path)

names = dir(path);  
names = {names.name};
c = length(names);
names = names(3:c); % final name

% THIS ONE FOR PLOTTING

for i=1:(c-2)

    A = load(char(names(i)));   % load file with corresponding name

    namesz = cell2mat(names(i));
    namesz = namesz(1:end-4);

    XX = ismember(area(:,1),namesz);
    index = find (XX);
    output_area = cell2mat(area(index,2));

    stress = A(:,3)/output_area*1000; % in MPa
    strain = A(:,4)/10^6;

                                         % plot the graph
    plot(strain,stress,'b')
    xlim([0 0.12])
    ylim([0 1000])
    ylabel('Stress [MPa]')
    xlabel('Strain')
    title (file,'interpreter','none')
    grid on
    grid minor
    hold on

    name(i) = {namesz};
    % find elastic modulus
    elastic_modulus(i) = stress(400)/strain(400);            % from stress(400)

    % curve and offset for intersection
    curve = [strain stress];                    % make matrix 
    curve_lim = curve(1:732,:);                % take first 1000 (change for DA...)
    offset_strain = curve_lim(:,1);             % take the strain
    offset_stress = elastic_modulus(i)*offset_strain-elastic_modulus(i)*0.002;    % line function
    offset = [offset_strain offset_stress];     % make matrix

    difference = abs(curve_lim-offset);         % difference 

    minimum = min(difference);                  % minimum difference

    loc = find (difference(:,2) == minimum(2));   % loaction of ^^

    sigma_yield(i) = offset(loc,2);                 % yield stress @ loc

    sigma_uts(i) = max(stress);
    breaking_strain(i) = max(strain);
    
end

% Calculating mean and sd
mean_elastic_modulus = mean(elastic_modulus);
sd_elastic_modulus = std(elastic_modulus);
mean_sigma_yield = mean(sigma_yield);
sd_sigma_yield = std(sigma_yield);
mean_sigma_uts = mean(sigma_uts);
sd_sigma_uts = std(sigma_uts);
mean_breaking_strain = mean(breaking_strain);
sd_breaking_strain = std(breaking_strain);
Average = [mean_elastic_modulus;mean_sigma_yield;mean_sigma_uts;mean_breaking_strain];
Standard_Deviation = [sd_elastic_modulus;sd_sigma_yield;sd_sigma_uts;sd_breaking_strain];
Parameters = {'Elastic Modulus';'Sigma_Yield';'Sigma_UTS';'Breaking Strain'};
% Preparing the table
name = name';
elastic_modulus = num2cell(elastic_modulus);
elastic_modulus = elastic_modulus';
sigma_yield = num2cell(sigma_yield);
sigma_yield = sigma_yield';
sigma_uts = num2cell(sigma_uts);
sigma_uts = sigma_uts';
breaking_strain = num2cell(breaking_strain);
breaking_strain = breaking_strain';
% result = [{name} {elastic_modulus'} {sigma_yield'} {sigma_uts'} {breaking_strain'}]

T = table(name,elastic_modulus,sigma_yield,sigma_uts,breaking_strain)
S = table(Parameters,Average,Standard_Deviation)
cd ../
savefig(file);
saveas(gcf,strcat(file,'.png'));
writetable(T,'result.txt');
writetable(S,'stats.txt');

% xlswrite('result.xls',result)

% T = table(result);
% 
% writetable(T, 'MyFile.txt')
% writetable(T,'tabledata2.txt','Delimiter','\t','WriteRowNames',true);

