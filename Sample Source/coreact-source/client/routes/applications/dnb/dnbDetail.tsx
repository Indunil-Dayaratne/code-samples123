import * as React from 'react'
import { supportsGoWithoutReloadUsingHash } from 'history/DOMUtils';
import { history} from '../../../App';
import {
  Frame,
  Navigation,
  TopBar,
  SkeletonPage,
  Layout,
  Card,
  TextContainer,
  SkeletonBodyText,
  SkeletonDisplayText,
  Loading,
  DataTable,
  Button,
  Page,
  TextField,
  Select,
  Stack,
  ResourceList,
  TextStyle,
  Tabs,
  List,
  Avatar,
  Spinner
} from '@shopify/polaris';
import { shallowEqual} from '../../../utils/shallowEqual';
import { connect } from 'react-redux';
import {
  getDetails,
  clearItemState

} from '../../../redux/dnb/dnbDetail/actions';

import { dnbApiExecutionList } from '../../../redux/dnb/dnbApiExecutionList'
import DnbDetailSkeletonLoading from './components/DnbDetailSkeletonLoading'

import DnbDetailDashboard from './components/DnbDetailDashboard';

import DnbpCIDetail from './components/DnbpCIDetail'
import DnbpKYCDetail from './components/DnbpKYCDetail';

import JsonView from 'react-pretty-json';



interface IDnbDetailProps {
  dnbpciLoading: boolean,
  dnbpkycLoading: boolean,
  dnbpviLoading: boolean,
  dnbpclLoading: boolean,
  dnbpmlLoading: boolean,
  dnbpownLoading: boolean,
  dnbpcompLoading: boolean,
  dnbRemoteSearch: any,
  dnbDetail: any,
  getDetails: any,
  selectedRemoteSearchItem: any,
  match : any,
  clearItemState: any
}

class DnbDetailsApplication extends React.Component<IDnbDetailProps,any> {
  constructor(props :any) {
    super(props);

    console.log('here');

    this.handleTabChange = this.handleTabChange.bind(this);

    this.state = {
      dropdownSplitOpen: false,
      selectedComponent: 'dash',
      showMobileNavigation: false
    };

    this.handleViewClick = this.handleViewClick.bind(this);
  }

  handleTabChange = (selectedTabIndex) => {
    this.setState({selectedTab: selectedTabIndex});
  };

  componentDidMount() {
    this.props.getDetails(this.props.dnbRemoteSearch.selectedRemoteSearchItem.DUNSNumber);
  }


  handleSearchClick() {
    // nvaigate
    history.push("/")
  }

  handleViewClick(selectedComponent) {
    this.setState({ selectedComponent : selectedComponent});
  }

  renderDnbComponentNavigation() {
    let components = Array<any>();

    dnbApiExecutionList.map((item: any, index) => {
      components.push({ label: item.content,tabId: item.id, panelid: item.panelId, YonClick:() => this.handleViewClick(item.id)  })
    });

    return components;
  }

  getSelectedComponent(id: string) {
    let item : any = dnbApiExecutionList.find(x => x.id === id);

    return item.component;
  }

  getCurrentItem() {
    let item : any = dnbApiExecutionList.find(x => x.id === this.state.selectedComponent);

    return item;
  }

  toggleState = (key) => {
    return () => {
      this.setState((prevState) => ({[key]: !prevState[key]}));
    };
  };
  render() {

    const {
      dnbpkycData,
      dnbpkycLoading ,
      dnbpviData,
      dnbpviLoading ,
      dnbpclData,
      dnbpclLoading ,
      dnbpownData,
      dnbpprLoading ,
      dnbpcrLoading ,
      dnbpmlLoading ,
      dnbplebLoading ,
      dnbplesLoading ,
      dnbplejLoading ,
      dnbpmedLoading ,
      dnbpciLoading ,
      dnbpownLoading ,


    } = this.props.dnbDetail;

    const {
      selectedRemoteSearchItem
    } = this.props.dnbRemoteSearch

    const title = selectedRemoteSearchItem.OrganizationPrimaryName.OrganizationName.$ + " (" +selectedRemoteSearchItem.DUNSNumber + ")";

    const { selectedTab, showMobileNavigation } = this.state;

    const cards = [
      (<Card key='dash'>
        <DnbDetailDashboard />
      </Card>),
      (<Card key='ci'>{ !dnbpciLoading ? (<DnbpCIDetail />): <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='kyc'>{ !dnbpkycLoading ? (<DnbpKYCDetail />): <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='own'>{ !dnbpownLoading ? (this.props.dnbDetail.dnbpownData != undefined ? (<JsonView json={this.props.dnbDetail.dnbpownData} />): <p>No data available</p>) : <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='cl'>{ !dnbpclLoading ? (this.props.dnbDetail.dnbpclData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbpclData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='ml'>{ !dnbpmlLoading ? (this.props.dnbDetail.dnbpmlData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbpmlData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='les'>{ !dnbplesLoading ? (this.props.dnbDetail.dnbplesData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbplesData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='lej'>{ !dnbplejLoading ? (this.props.dnbDetail.dnbplejData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbplejData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='leb'>{ !dnbplebLoading ? (this.props.dnbDetail.dnbplebData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbplebData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='cr'>{ !dnbpcrLoading ? (this.props.dnbDetail.dnbpcrData != undefined ? (<JsonView json={this.props.dnbDetail.dnbpcrData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='pr'>{ !dnbpprLoading ? (this.props.dnbDetail.dnbpprData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbpprData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>),
      (<Card key='vi'>{ !dnbpviLoading ? (this.props.dnbDetail.dnbpviData != undefined ?  (<JsonView json={this.props.dnbDetail.dnbpviData} />): <p>No data available</p>) :  <DnbDetailSkeletonLoading />} </Card>)
    ];

    const topBarMarkup = (
      <TopBar
        showNavigationToggle={true}
        onNavigationToggle={this.toggleState('showMobileNavigation')}
      />
    );

    const renderNavigation = (
      <Navigation location='' >
        <Navigation.Section
          items={[
          {
            label: ' Back to Search',
            onClick: this.handleSearchClick,
            icon: 'arrowLeft'
          }
          ]}
        />
        <Navigation.Section separator
         items={this.renderDnbComponentNavigation()}
        />
      </Navigation>
    )



    return (
      <Frame navigation={renderNavigation}
      showMobileNavigation={showMobileNavigation}
      topBar={topBarMarkup}
      onNavigationDismiss={this.toggleState('showMobileNavigation')}
      >
        <Page fullWidth title={title} >
          { cards.find(x => x.key === this.state.selectedComponent)}
        </Page>
      </Frame>
    )
    }
  }

const mapStateToProps = ({  dnbDetail, dnbRemoteSearch }) => {
  return {
    dnbDetail,
    dnbRemoteSearch
  };
};

export default connect(
  mapStateToProps,
  {
    getDetails,
    clearItemState
  },
  null,
  {
    areStatesEqual: (next, prev) => { return (shallowEqual(next,prev)) }
  }
)(DnbDetailsApplication);
