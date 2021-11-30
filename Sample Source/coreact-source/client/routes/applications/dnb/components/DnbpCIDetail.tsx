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

class DnbpCIDetail extends React.Component<any,any> {

  constructor(props: any) {
    super(props);
    this.state = {
      dnbComponent: dnbApiExecutionList.find(x => x.id === 'ci'),
    }
  }

  renderLoading() {
    return (
      <DnbDetailSkeletonLoading />
    )
  }

  renderSummary() {
    const {
      dnbpciLoading,
      dnbpciData

    } = this.props.dnbDetail;

    if(dnbpciData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpciData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpciData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

      let renderArray : Array<JSX.Element> = [];

      if(orgData != undefined)
      {
        if(orgData.SubjectHeader.OrganizationSummaryText)
        {
          const summaryText =(
            <Card.Section title="Summary" key="summary">
            { orgData.SubjectHeader.OrganizationSummaryText }
            </Card.Section>
          )

          renderArray.push(summaryText);
        }


        if(orgData.ActivitiesAndOperations.LineOfBusinessDetails)
        {
          const lineOfBusiness = (
            <Card.Section title="Line of Business" key="lob">
              <p>{ orgData.ActivitiesAndOperations.LineOfBusinessDetails[0].LineOfBusinessDescription.$ }</p>
            </Card.Section>
          )

          renderArray.push(lineOfBusiness);
        }

        const activities= (
          <Card.Section title="Activities" key="Activities" >
            <List type="bullet">
              { orgData.ActivitiesAndOperations.LineOfBusinessDetails.ImportDetails != undefined  &&  orgData.ActivitiesAndOperations.LineOfBusinessDetails.ImportDetails.ImportIndicator === "true" ?
                <List.Item key="importer">Importer</List.Item> : null
              }
              { orgData.ActivitiesAndOperations.LineOfBusinessDetails.ExportDetails != undefined  &&  orgData.ActivitiesAndOperations.LineOfBusinessDetails.ExportDetails.ExportIndicator === "true" ?
                <List.Item key="exporter">Exporter</List.Item> : null
              }
              { orgData.ActivitiesAndOperations.LineOfBusinessDetails.SubjectIsAgentDetails != undefined  &&  orgData.ActivitiesAndOperations.LineOfBusinessDetails.SubjectIsAgentDetails.AgentIndicator === "true" ?
                <List.Item key="agent">Agent</List.Item> : null
              }
            </List>
          </Card.Section>
        )

        renderArray.push(activities);

        const employees = (
          <Card.Section title="Other" key="other" >
            <p>Number of Employees: { orgData.EmployeeFigures.ConsolidatedEmployeeDetails.TotalEmployeeQuantity} </p>

            { orgData.PrincipalsAndManagement != undefined && orgData.PrincipalsAndManagement.CurrentPrincipal != undefined && orgData.PrincipalsAndManagement.CurrentPrincipal[0] != undefined ?
              <p>Current Principal: { orgData.PrincipalsAndManagement.CurrentPrincipal[0].PrincipalName.FullName }</p> : null
              }
            { orgData.PrincipalsAndManagement != undefined && orgData.PrincipalsAndManagement.CurrentPrincipal != undefined && orgData.PrincipalsAndManagement.CurrentPrincipal[0].JobTitle != undefined ?
              <p>Principal Job Title: { orgData.PrincipalsAndManagement.CurrentPrincipal[0].JobTitle[0].JobTitleText.$ }</p> : null
              }
          </Card.Section>
        )

        renderArray.push(employees);

        return renderArray;
      }
      else return (
          <Card.Section title="Summary">
          <p>No data available</p>
        </Card.Section>)
      }
      else return (
        <Card.Section title="Summary">
        <p>No data available</p>
      </Card.Section>)
  }

  renderIndustry() {

    const {
      dnbpciLoading,
      dnbpciData

    } = this.props.dnbDetail;

    if(dnbpciData.OrderProductResponse.OrderProductResponseDetail != null
      && dnbpciData.OrderProductResponse.OrderProductResponseDetail.Product != null)
    {
      let orgData : any = dnbpciData.OrderProductResponse.OrderProductResponseDetail.Product.Organization;

    if(orgData != undefined && orgData.IndustryCode != undefined && orgData.IndustryCode.IndustryCode != undefined)
    {
      const valueArray = orgData.IndustryCode.IndustryCode as [];

      const renderIndustryCodes = (
        <Card.Section title="Industry Codes">
          <ResourceList resourceName={{ singular: 'Industry Code', plural: 'Industry Codes'}}
        items={valueArray}
        renderItem={(item: any) => {
          const id : string = item['@DNBCodeValue'];
          const desc : string = item.IndustryCodeDescription[0].$
          const code : string = item.IndustryCode.$
          return (
            // @ts-ignore
            <ResourceList.Item id={id} key={id} >
                <Stack key={id}>
                  <p>{code} : {desc}</p>
                </Stack>
            </ResourceList.Item>
          );
        }}
        />
        </Card.Section>)

      return renderIndustryCodes;
    }
    else
     return (
        <Card.Section title="Industry Codes">
        <p>No data available</p>
      </Card.Section>);
    } else return (
      <Card.Section title="Industry Codes">
      <p>No data available</p>
    </Card.Section>);
  }

  renderLoaded() {
    return [
      this.renderSummary(),this.renderIndustry()
    ]
  }

  render() {
    const {
      dnbpciLoading,
    } = this.props.dnbDetail;

    return (
      <React.Fragment>
        <Page fullWidth title={this.state.dnbComponent.content} >
          <Card>
            { !dnbpciLoading ? this.renderLoaded() : this.renderLoading()}
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
)(DnbpCIDetail);
