
import { DnbRemoteSearchState} from './dnb/models'
import { ProcessState}  from './process/models'
import { AADState } from './aad/models';
import { DnbDetailState } from './dnb/dnbDetail/models'

export interface ApplicationState {
  dnbRemoteSearch: DnbRemoteSearchState
  dnbDetail: DnbDetailState
  process: ProcessState
  aad: AADState
}


