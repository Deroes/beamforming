clear all

c = 340;
T = 0.1;
fs = 44e3;
t = 0:1/fs:T-1/fs;
dBmin = 60;
nSamples = fs*T;

%Choose scanning angles
thetaScanningAngles = -90:0.1:90;
phiScanningAngles = 0;

%Set parameters of incoming signal(s)
f = [1 1]*3e3;
thetaArrivalAngles = [-15 5];
phiArrivalAngles = [0 0];
amplitudes = [0 2]; %difference in dB levels

%Load array
load ../../data/arrays/S1.mat
w = hiResWeights;
%load ../arrays/gfai-72.mat
%load arrays/gfai-48.mat

inputSignal = 0;
max_spectrum_val = 0;
figure(1);clf
for j = 1:numel(f)

    %Create signal hitting the array
    signal = createSignal(xPos, yPos, f(j), c, fs, thetaArrivalAngles(j), phiArrivalAngles(j), amplitudes(j));
    inputSignal = inputSignal + signal;
    
    %Calculate steered response for individual signals
    S(j,:) = steeredResponseDelayAndSum(xPos, yPos, w, signal, f(j), c, thetaScanningAngles, phiScanningAngles);

    %Need to save the max value of individual spectra
    %for normalisation purposes
    if max(abs(S(j,:))) > max_spectrum_val
        max_spectrum_val = max(abs(S(j,:)));
    end
    
end


%Calculate steered response in frequency domain
S_tot = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f(1), c, thetaScanningAngles, phiScanningAngles);
S_tot = abs(S_tot)/max(abs(S_tot)); %normalisation


%Plot individual beampatterns
subplot(2,2,[1 2])
hold on
for j=1:numel(f)
    S(j,:) = abs(S(j,:))/max_spectrum_val;%normalisation
    plot(thetaScanningAngles,10*log10(S(j,:)),'DisplayName',[num2str(f(j)*1e-3) 'kHz'])
end
axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])
grid on
xlabel('\theta')
ylabel('dB')
title('Beampattern of individual signals','FontWeight','Normal')
legend(gca,'show')
yL = get(gca,'YLim');
for j=1:numel(f)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');
end

%Plot steered response
subplot(223)
plot(thetaScanningAngles,10*log10(S_tot))
xlabel('\theta')
ylabel('dB')
grid on
axis([thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])
yL = get(gca,'YLim');
for j=1:numel(f)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');
end
title('Combined beampattern','FontWeight','Normal')

%Plot zoomed steered response
subplot(224)
plot(thetaScanningAngles,10*log10(S_tot))
xlabel('\theta')
ylabel('dB')
grid on
axis([min(thetaArrivalAngles)-10 max(thetaArrivalAngles)+10 -3 0])
yL = get(gca,'YLim');
for j=1:numel(f)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');
end
title('Zoomed beampattern','FontWeight','Normal')
set(gca,'YTick',[-20 -15 -10 -6 -3 -2 -1 0])
