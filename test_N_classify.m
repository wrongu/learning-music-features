function ERRS = test_N_classify(X, Y, PERC_TRAIN_SET, N_TOTAL_TESTS, K)
    N = size(X,1);

    N_TRAIN = floor(N*PERC_TRAIN_SET);

    ERRS = zeros(N_TOTAL_TESTS, 1);

    for i=1:N_TOTAL_TESTS

        fprintf('TEST %d\n', i);

        scramble = randperm(N);

        trainX = X(scramble(1:N_TRAIN),:);
        trainY = Y(scramble(1:N_TRAIN));
        testX = X(scramble(N_TRAIN+1:end),:);
        testY = Y(scramble(N_TRAIN+1:end));

        guessY = knnclass(trainX, trainY, testX, K);

        correct = arrayfun(@(i) strcmp(testY{i}, guessY{i}), 1:length(guessY));

        ERRS(i) = 100*(1-sum(correct)/length(correct));
    end
end