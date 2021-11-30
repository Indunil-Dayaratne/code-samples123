import programHandler from './programHandler';
import analysisHandler from './analysisHandler';
import rdmHandler from './rdmHandler';
import pricingHandler from './pricingHandler';
import clfHandler from './clfHandler';
import groupHandler from './groupHandler';
import resultsHandler from './resultsHandler';
import fileHandler from './fileHandler';
import submissionHandler from './submissionHandler';
import rpxHandler from './rpxHandler';
import cedeHandler from './cedeHandler';
import lossSetHandler from './lossSetHandler';
import pricingNetworkUpdater from './pricingNetworkUpdater';
import taskHandler from './taskHandler';
import graphene from './grapheneRequestHandler';
import functionRequestHelper from './functionRequestHelpers';
import queueStatusHandler from './queueStatusHandler';

export default {
    ...programHandler,
    ...analysisHandler,
    ...rdmHandler,
    ...clfHandler,
    ...pricingHandler,
    ...groupHandler,
    ...resultsHandler,
    ...fileHandler,
    ...submissionHandler,
    ...rpxHandler,
    ...cedeHandler,
    ...lossSetHandler,
    pricingNetworkUpdater,
    ...taskHandler,
    graphene,
    navigateWithToken: functionRequestHelper.navigateWithToken,
    ...queueStatusHandler
}