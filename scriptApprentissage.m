***************************
% le nombre de re-apprentissage 
nbrRetrain = 3 ;

%un compteur pour remplir une matrice qui contient toute les statitstiques de l'apprentissage
cptTrain = 1;


% import des données ( input , output ) 
inputRange = 'B:X';
targetRange = 'Y:Y';

input      =  xlsread('G:\AARN\Projet\dataSet\default of credit card clients TargetModify1.xls',inputRange);
target      = xlsread('G:\AARN\Projet\dataSet\default of credit card clients TargetModify1.xls',targetRange);
input = input';
target = target';


%import des fichiers contienent les informations sur les archutectures utilisé durant l'apprentissage  
file1Couche = 'G:\AARN\Projet\MatrixOfLayersUsed\1couche.csv';
file2Couche = 'G:\AARN\Projet\MatrixOfLayersUsed\2couche.csv';   
file3Couche = 'G:\AARN\Projet\MatrixOfLayersUsed\3couche.csv';  


matrixOneLayer      = csvread(file1Couche, 0, 0);
matrixTwoLayer 		= csvread(file2Couche, 0, 0);   
matrixthreeLayer    = csvread(file3Couche, 0, 0);



%Tables de statistique:
tableStrucInfo = {'Perfermence';'Regression';'configuration';'fonction de transfer';'fonction activation'};
%***********************************************************************************************************



%%%%%%%%%%%%%%%%%%%%%%%%% 1 er   boucle  pour changer la fonction d'appretissage %%%%%%%%%%%%%%%%%%%%%%%%%
for netWorkTrainFunction=1:5 % Different Training   ---------------------------------------------------- 1      

	% cette variable juste pour récupérer la fonction d'apprentissage chaque itération (boucle)
	trainFcn=''; 
		
 		% pour choisir la fonction de training
			switch netWorkTrainFunction
					    case 1 
					        trainFcn = 'trainlm';
					    case 2
					        trainFcn = 'trainrp';
					    case 3 
					        trainFcn = 'trainbr';
					    case 4
					        trainFcn = 'trainscg';
					    case 5
					        trainFcn = 'trainr';   
			end % fin de switch
		


	%%%%%%%%%%%%%%%%%%%%%%%%%  2 em   boucle  pour le choix de la fonction d'activation %%%%%%%%%%%%%%%%%%%%%%%%%
	for iTransfer = 1:3 % tranfer Function  ---------------------------------------------------------------------3
	

		switch iTransfer %---------------------------
				case 1   								%
						tranferFnc = 'logsig';		%	
				case 2   								%
				 		tranferFnc = 'tansig';		%
			 	case 3   								%	
				 		tranferFnc = 'purelin';		%
		 											%
	        end %---------------------------------------

					
		for numberOfLayer = 1:3  % combien de couche pour chaque test sur chaque fonction choisi ------------- 2
							%vider le tableau de layers 
							clearvars layerTable
							% pour creer un tableau de i case 
							% chaque case represente une couche caché 
							% chaque couche caché contient un nombre de neurones 
							
							%layerTable(i)= (numberOfLayer-i+1)*5								
							 switch numberOfLayer %--------------------------
							 	case 1       					%
									matrixUsed = matrixOneLayer;		%	
								case 2   					%
							 		matrixUsed = matrixTwoLayer;		%
								case 3 						%	
							 		matrixUsed = matrixthreeLayer;		%
														%
							 end %---------------------------------------------------	
							 
							 [line,column] = size(matrixUsed);
	
           for mat = 1 : line  %----------------- pour chaque configuration de notre réseau (par exemple (net(25,10,10))) ----- 4 	
								%layerTable : c'est un tableau qui contient l'architecture utilisé 
								layerTable  = matrixUsed(mat,:);
								% create the neural network now , using the table of layers 
								%------------------------------------
								clearvars mSlope bOffset regression     %
								% our network 				%
								net = feedforwardnet(layerTable) ;	%
								net = configure(net,input,target);	%
				 				%---------------------------------------%
								%affectation d'une fonction d'apprentissage a notre reseau :
								net.trainFcn = trainFcn;
	
								% ASSIGN  THE TRANSFER FUNCTION  ---------------------------%
								%		    					    %				
								for layerNbr = 1:column 				    %
								net.layers{layerNbr}.transferFcn = tranferFnc ;		    %
								end % ------------------------------------------------------% 	
										
								sommeOfPerf = 0 ;
								sommeOfRegression = 0;
										

					 for retrainN = 1:nbrRetrain %***********************************************RETRAIN***********************************

						% reinitialisé les poids 			
						net = init(net);
																
						% do training 
						[net,tr] = train(net,input,target);

						outPut = net(input) ;  
						
						%e = gsubtract(target,outPut);      
						perf=perform(net,outPut,target);
  						%aprés avoir le outPut , on peut calculer la régression 
						[regression,mSlope,bOffset]  = regression(target,outPut);

						regres = regression(1);
					        sommeOfPerf = sommeOfPerf+perf;							
						sommeOfRegression =sommeOfRegression+regres;
						clearvars mSlope bOffset regression;		
						end	%*****************************************************************************					 
						perf = sommeOfPerf / nbrRetrain ;
						regres = sommeOfRegression /nbrRetrain ;

						%pour recuperer l architecture de network 
						layerTableString=''; 
						
						%Sauvgarder les resultat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						tablePerfermance(cptTrain)= perf;
						tableRegression(cptTrain)=regres;
						tableStructure.newVar(cptTrain)= {int2str(layerTable)};
						tableTransferFunction.newVar(cptTrain)={tranferFnc};
						tableTrainFunction.newVar(cptTrain)={trainFcn};
						cptTrain = cptTrain+1;
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	


					 end	%----------------------------------------------------------------------------------------------------------------fin 4
														




							end	%---------------------------------------------------------------------------------------------------------------------------------------------3


																		



%%%%%%%%%%%%%%%%%%%%%%%%% si vous voulez sauvgarder les graphes des regression et perfermances %%%%%%%%%%%%%%%%%%%%%%%%%

							% Plots

							%figure, plotperform(tr);
							%saveas(gcf,strcat('G:\\AARN\\Projet\\plotperfomB',trainFcn,netWorkTrainFunction,'.png');

							%figure, plotregression(t,y);
							%saveas(gcf,strcat('G:\\AARN\\Projet\\regressionB',trainFcn,netWorkTrainFunction,'.png');




		end %---------------------------------------------------------------------------------------------------------------------------------------------------------- 2	

end %------------------------------------------------------------------------------------------------------------------------------------------------------------- fin 1  




%***********************************************************************************
tStruct = tableStructure.newVar' ;
tTrain = tableTrainFunction.newVar';

tRegress = tableRegression'; 
tRegress = num2cell(tRegress);

tPerferm = tablePerfermance';
tPerferm =num2cell(tPerferm);

tabx = [ tPerferm , tRegress , tStruct, tTrain ]; 


file ='G:\AARN\Projet\MatrixOfLayersUsed\statistiqueTable.mat'; 

save(file, 'tabx');
ax = load('G:\AARN\Projet\MatrixOfLayersUsed\statistiqueTable.mat');
ax = ax.tabx;


%***********************************************************************************

%Juste pour supprimer les les variables déja utilsié:     
%------------------------------------------------

	clearvars tableStructure tablePerfermance tableRegression tableStrucInfo tableTrainFunction 
	clearvars layerTable layerTableString layerTableString  tableTransferFunction 
	clearvars  perf  regres  net netWorkTrainFunction numberOfLayer outPut  retrainNBR  sommeOfPerf sommeOfRegression bestPerf file1Couche file2Couche file3Couche
	clearvars column line  cptTrain  e  iTransfer   layerNbr  tr trainFcn matrixUsed   tranferFnc ans retrainN matrixthreeLayer matrixOneLayer matrixTwoLayer
	clearvars input inputRange targetRange target mat nbrRetrain tRegress tStruct tPerferm tTrain tabx ax file  

%************************************************************ variables : ******************************************
