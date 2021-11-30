import * as React from 'react'
import { httpWrapper } from '../../../../utils/httpFunctions'
import jsonQuery from 'json-query'
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
import { dnbApiExecutionList } from '../../../../redux/dnb/dnbApiExecutionList'
import { connect } from 'react-redux';
import { shallowEqual} from '../../../../utils/shallowEqual';
import axios from 'axios'
import { renderToStaticNodeStream } from 'react-dom/server';
import { IdToken } from 'msal/lib-commonjs/IdToken';
import DnbDetailSkeletonLoading from './DnbDetailSkeletonLoading';
import { render } from 'react-dom';

class DnbpKYCDetail extends React.Component<any,any> {

  constructor(props: any) {
    super(props);
    this.state = {
      dnbComponent: dnbApiExecutionList.find(x => x.id === 'kyc'),
    }
  }

  renderCompanySanctions() {
    const {
      dnbpkycLoading,
      dnbpkycData

    } = this.props.dnbDetail;

    if(dnbpkycData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

    if(orgData.ComplianceDetail.SanctionDetail != undefined) {
      const fArray = orgData.ComplianceDetail.SanctionDetail.CompanySanctionDetail as [];

      let tableData: Array<any> = [];
      let rowData: Array<any> = [];

      fArray.forEach((item: any,index) => {

        rowData.push(item.SanctionsTypeText);
        rowData.push(item.SanctionsListName);
        if(item.SanctionsAuthorityWebPageAddress != undefined)
          rowData.push(item.SanctionsAuthorityWebPageAddress.TelecommunicationAddress);
        else
          rowData.push("");

        rowData.push(item.SanctionsAuthorityRegionText);

        if(item.SanctionsHomeWebPageAddress != undefined)
          rowData.push(item.SanctionsHomeWebPageAddress.TelecommunicationAddress);
        else
          rowData.push("");

        rowData.push(item.ActiveSanctionsIndicator.toString());
        rowData.push(item.MatchedIndicator.toString());

        tableData.push(rowData);
        rowData = [];
      })

      const sanctions = (
        <Card.Section title="Company Sanctions List" key="companySanctions">
          <DataTable
            columnContentTypes={['text','text','text','text','text','text','text']}
            headings={['Type','List Name','Authority Web page','Authority Region','Home Web Page','Active?','Sanctioned?']}
            rows={tableData}
          ></DataTable>
        </Card.Section>
      )

      return sanctions;
      }
      else return (<Card.Section title="Company Sanctions List" key="companySanctions"><p>No data available</p></Card.Section>)
    }
    else return (<Card.Section title="Company Sanctions List" key="companySanctions"><p>No data available</p></Card.Section>);
  }

  renderSanctions() {
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

      let tableData: Array<any> = [];
      let rowData: Array<any> = [];

      fArray.forEach((item: any,index) => {

        rowData.push(item.SanctionListName);

        if(item.SanctionsAuthorityWebPageAddress != undefined)
          rowData.push(item.SanctionsAuthorityWebPageAddress.TelecommunicationAddress);
        else
        rowData.push("");

        rowData.push(item.MatchedIndicator.toString());

        tableData.push(rowData);
        rowData = [];
      })

      const sanctions = (
        <Card.Section title="Country Sanctions List" key="countrySanctions">
          <DataTable
            columnContentTypes={['text','text','text']}
            headings={['List Name','Web page','Sanctioned?']}
            rows={tableData}
          ></DataTable>
        </Card.Section>
      )

      return sanctions;
      }
      else return (<Card.Section title="Country Sanctions List" key="countrySanctions"><p>No data available</p></Card.Section>)
    }
    else return (<Card.Section title="Country Sanctions List" key="countrySanctions"><p>No data available</p></Card.Section>)
  }

  renderStockExchange() {
    const {
      dnbpkycLoading,
      dnbpkycData

    } = this.props.dnbDetail;

    if(dnbpkycData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

      if(orgData.RegisteredDetail.StockExchangeDetails != undefined) {
        const fArray = orgData.RegisteredDetail.StockExchangeDetails as [];

        let tableData: Array<any> = [];
        let rowData: Array<any> = [];

        fArray.forEach((item: any,index) => {
          rowData.push(item.StockExchangeName != undefined ? item.StockExchangeName.$ : "");
          rowData.push(item.StockExchangeTickerName);

          tableData.push(rowData);
          rowData = [];
        })

        const stock = (
          <Card.Section title="Stock Exchange Details" key="stockExchangeDetails">
            <DataTable
              columnContentTypes={['text','text',]}
              headings={['Exchange Name','Ticker Name']}
              rows={tableData}
            ></DataTable>
          </Card.Section>
        )

        return stock;
      }
      else
        return (
          <Card.Section title="Stock Exchange Details">
            <p>No data available</p>
          </Card.Section>
        )
    }
    else return (
      <Card.Section title="Stock Exchange Details">
        <p>No data available</p>
      </Card.Section>
    );

  }

  renderFinancial() {
    const {
      dnbpkycLoading,
      dnbpkycData

    } = this.props.dnbDetail;

    if(dnbpkycData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpkycData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

      if(orgData.Financial != undefined) {
        const fArray = orgData.Financial.KeyFinancialFiguresOverview as [];

        let tableData: Array<any> = [];
        let rowData: Array<any> = [];

        fArray.forEach((item: any,index) => {
          rowData.push(item.StatementHeaderDetails.FinancialStatementToDate != undefined ? item.StatementHeaderDetails.FinancialStatementToDate.$ : "");
          rowData.push(item.CashAndLiquidAssetsAmount != undefined ? item.CashAndLiquidAssetsAmount.$ : "");
          rowData.push(item.SalesRevenueAmount != undefined ? item.SalesRevenueAmount.$ : "");
          rowData.push(item.TotalFixedAssetsAmount != undefined ? item.TotalFixedAssetsAmount.$ : "");
          rowData.push(item.TotalCurrentAssetsAmount != undefined ? item.TotalCurrentAssetsAmount.$ : "");
          rowData.push(item.TotalAssetsAmount != undefined ? item.TotalAssetsAmount.$ : "");
          rowData.push(item.TotalEquityAmount != undefined ? item.TotalEquityAmount.$ : "" );
          rowData.push(item.TotalCurrentLiabilitiesAmount != undefined ? item.TotalCurrentLiabilitiesAmount.$ : "");
          rowData.push(item.TotalNonCurrentLiabilitiesAmount != undefined ? item.TotalNonCurrentLiabilitiesAmount.$ : "");
          rowData.push(item.TotalLiabilitiesAmount != undefined ? item.TotalLiabilitiesAmount.$ : "");

          tableData.push(rowData);
          rowData = [];
        })

        const financials = (
          <Card.Section title="Key Financials" key="keyfinancials">
            <DataTable
              columnContentTypes={['text','numeric','numeric','numeric','numeric','numeric','numeric','numeric','numeric','numeric']}
              headings={['Date','Assets','Sales Revenue','Fixed Assets','Current Assets','Total Assets','Equity Amount','Current Liabilities','Total Non Current Liabilities','Total Liabilities']}
              rows={tableData}
            ></DataTable>
          </Card.Section>
        )

        return financials;
      }
      else
        return (<Card.Section title="Key Financials" key="keyfinancials"><p>No data available</p></Card.Section>)
    }
    else
    return (<Card.Section title="Key Financials" key="keyfinancials"><p>No data available</p></Card.Section>)
  }

  renderLoaded() {
    return [
      this.renderFinancial(),this.renderStockExchange(),this.renderSanctions(),this.renderCompanySanctions()
    ]
  }

  renderLoading() {
    return (
      <DnbDetailSkeletonLoading />
    )
  }

  render() {
    const {
      dnbpkycLoading,
    } = this.props.dnbDetail;

    return (
      <React.Fragment>
        <Page fullWidth title={this.state.dnbComponent.content} >
          <Card>
            { !dnbpkycLoading ? this.renderLoaded() : this.renderLoading()}
          </Card>
        </Page>
      </React.Fragment>
    )
  }
}

const mapStateToProps = ({ aad, dnbRemoteSearch, dnbDetail }) => {
  return {
    dnbDetail,
    dnbRemoteSearch,
    aad
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
)(DnbpKYCDetail);
