import * as React from 'react';
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
  Heading,
  Tabs,
  List,
  DisplayText,
  Avatar,
  Spinner
} from '@shopify/polaris';


import { connect } from 'react-redux';
import { shallowEqual} from '../../../../utils/shallowEqual';

 class DnbDetailDashboard extends React.Component<any,any> {

  constructor(props: any) {
    super(props);

  }

  renderDetail(title: string) {
    return (
      <Card title={title} sectioned>
        <p>{this.props.name}</p>>
      </Card>
    )
  }

  renderKycCountrySanctions() {
    const {
      dnbpkycLoading,
      dnbpkycData

    } = this.props.dnbDetail;

    if(dnbpkycData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product != null)
      {
      let orgData : any = dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

      if(orgData.ComplianceDetail.SanctionDetail != undefined) {
        const fArray = orgData.ComplianceDetail.SanctionDetail.CountrySanctionDetail as [];

        let totalSanctions = 0;

        fArray.forEach((item: any,index) => {
          if(item.MatchedIndicator.toString() === 'true')
          {
            totalSanctions++;
          }
        })

        const sanctions = (
          <Card title="Country Sanctions" sectioned>
           <DisplayText size="extraLarge">{ totalSanctions }</DisplayText>
          </Card>
        )

        return sanctions;
      }
      else return (<Card title="Country Sanctions" sectioned>
        <p>Data not available</p>
       </Card>)
    }
    else return (<Card title="Country Sanctions" sectioned>
        <p>Data not available</p>
       </Card>)

  }

  renderKycCompanySanctions() {
    const {
      dnbpkycData,
      dnbpkycLoading
    } = this.props.dnbDetail;

    if(dnbpkycData.OrderProductResponse.OrderProductResponseDetail != null
        && dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

      if(orgData.ComplianceDetail.SanctionDetail != undefined) {
        const fArray = orgData.ComplianceDetail.SanctionDetail.CompanySanctionDetail as [];

        let totalSanctions = 0;

        fArray.forEach((item: any,index) => {
          if(item.MatchedIndicator.toString() === 'true')
          {
            totalSanctions++;
          }
        })

        const sanctions = (
          <Card title="Company Sanctions" sectioned>
          <DisplayText size="extraLarge">{ totalSanctions }</DisplayText>
          </Card>
        )

        return sanctions;
      }
      else return (<Card title="Country Sanctions" sectioned>
       <p>Data not available</p>
      </Card>)
    }
    else return (<Card title="Country Sanctions" sectioned>
       <p>Data not available</p>
      </Card>)
  }

  render() {

    const {
      dnbpkycData,
      dnbpkycLoading ,
      dnbpviData,
      dnbpviLoading ,
      dnbpclData,
      dnbpclLoading ,
      dnbpownData,
      dnbpownLoading ,
      dnbpciData,
      dnbpciLoading,

    } = this.props.dnbDetail;

    return (
      <React.Fragment>
        <Page fullWidth title="Dashboard" >
          <Layout>
            <Layout.Section secondary>{ !dnbpkycLoading ? this.renderKycCountrySanctions() : <Spinner /> }</Layout.Section>
            <Layout.Section secondary>{ !dnbpkycLoading ? this.renderKycCompanySanctions() : <Spinner /> }</Layout.Section>
          </Layout>
        </Page>
      </React.Fragment>
    )
  }
}

const mapStateToProps = ({  dnbDetail }) => {
  return {
    dnbDetail
  };
};

export default connect(
  mapStateToProps,
  {
  },
  null,
  {
    areStatesEqual: (next, prev) => { return (shallowEqual(next,prev)) }
  }
)(DnbDetailDashboard);
