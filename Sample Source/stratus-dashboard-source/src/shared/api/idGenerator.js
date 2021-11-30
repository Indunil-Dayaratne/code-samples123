function getOldId(lower = -100, upper = 100) {
    return new Date().getTime() + Math.floor(Math.random() * (upper - lower)) + lower;
}

function getOldIdGenerator (lower, upper) {
    return function() {
        const output = getOldId(lower, upper);
        console.log(`ID generated: ${output}`);
        return output;
    }
}

function getIdGenerator() {
    let options = [];
    return function() {
        if(options.length < 50) {
            options = []
            const start = new Date().getTime();
            for (let i = 0; i < 1000; i++) {
                options.push(start + i);
            }
        }
        const output = options.shift();
        //console.log(`ID generated: ${output}`);
        return output;
    }
}

function getMultipleIds(generator, length) {
    const output = [];
    for (let i = 0; i < length; i++) {
        output.push(generator())        
    }
    return output;
}

function checkGetIdUniqueness(generator, length) {
    const ids = getMultipleIds(generator, length);
    const set = new Set(ids);
    return {
        totalIds: length,
        uniqueIds: set.size
    }
}



function checkGetIdUniquenessBatch(generator, batchSize, checkCount) {
    let nonTotalUniqueCount = 0;
    for (let i = 0; i < checkCount; i++) {
        const idCheck = checkGetIdUniqueness(generator, batchSize)
        if(idCheck.totalIds != idCheck.uniqueIds) nonTotalUniqueCount++;
    }
    return {
        totalBatches: checkCount,
        batchSize: batchSize,
        nonUniqueBatchCount: nonTotalUniqueCount
    }
}

export default {
    getOldIdGenerator,
    getIdGenerator,
    getMultipleIds,
    checkGetIdUniqueness,
    checkGetIdUniquenessBatch
}