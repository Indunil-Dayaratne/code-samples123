import * as React from 'react'

import {
  Frame,
  Navigation,
  TopBar,
  SkeletonPage,
  Layout,
  Card,
  Checkbox,
  Button,
  Page,
  TextField,
  Select,
  Stack,
  ResourceList,
  TextStyle,
  List,
  Spinner,
  Avatar
} from '@shopify/polaris';

import Pagination from 'react-js-pagination'
import { shallowEqual } from '../../../utils/shallowEqual';
import { connect } from "react-redux";
import * as models from '../../../redux/dnb/models';
import {
  remoteSearch,
  remoteSearchGetDetails
} from '../../../redux/dnb/dnbRemoteSearch/actions'

import { CountriesJson} from '../../../data/countries'
import { renderToString } from 'react-dom/server';

class DnbListApplication extends React.Component<any,any> {
  constructor(props) {
    super(props);

    this.handleKeywordChange = this.handleKeywordChange.bind(this)
    this.handleChangeSelectedCountry = this.handleChangeSelectedCountry.bind(this)
    this.handleChangeActive = this.handleChangeActive.bind(this)
    this.handleReset = this.handleReset.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)

    this.state = {
      searchKeyword: "",
      selectedCountryLabel: null,
      selectedCountry : "gb",
      selectedActive: true
    };
  }

  handleChangeActive(selected,id) {
    this.setState({selectedActive : selected});
  }

  handleChangeSelectedCountry(selected,id) {
    this.setState({selectedCountry : selected});
    this.setState({selectedCountryLabel : id});
  }

  handleReset() {
    this.setState({ searchKeyword : ""});
    this.setState({ selectedCountry :"gb"})
    this.setState({ selectedActive : true})

    this.props.dnbRemoteSearch.allItems = [];
  }

  handleSubmit() {
      let options : models.DnbRemoteSearchOptions = {
        searchKeyword: this.state.searchKeyword,
        selectedCountry: this.state.selectedCountry,
        selectedActive: this.state.selectedActive
      }

      this.props.remoteSearch(options);
  }

  handleKeywordChange(value,id) {
    this.setState({searchKeyword : value});
  }

  handleEnterPressSearch(e) {
    if (e.key === "Enter") {
      this.setState({searchKeyword : e.target.value},() =>
      {
        this.handleSubmit();
      });
    }
  }

  getCountrySelect() {
    let countrySelect = [];

    return CountriesJson.map((item) => {
      return {
        label: item.name,
        value: item.alpha2
      }
    })
  }

  render() {
    const {
        allItems,
        loading,
        numberOfItemsFound,
        searchOptions
    } = this.props.dnbRemoteSearch;

    const pageHeaderMarkup = (
      <Card title="Search Options" sectioned>
        <Stack>
          <Select label="Country" labelInline options={ this.getCountrySelect()}
            onChange={this.handleChangeSelectedCountry}
            value={this.state.selectedCountry}
          />
          <div onKeyDown={this.handleEnterPressSearch}><TextField label="Search" value={this.state.searchKeyword} labelHidden={true} onChange={this.handleKeywordChange} /></div>
          <Checkbox checked={ this.state.selectedActive } label='Active Companies Only' onChange={this.handleChangeActive } />
          <Button primary onClick={() => this.handleSubmit()}>Search</Button>
          <Button onClick={() => this.handleReset()} >Reset</Button>
        </Stack>
      </Card>
    )
    const loadingMarkup = (
      <Stack alignment="center"><Spinner size="large" color="teal" /></Stack>
    )
    const pageContentMarkup = (

      <Card>
         { !loading ? null :loadingMarkup }
         { allItems !== undefined ? (
        <ResourceList
          items={ allItems }
          resourceName={{singular: 'company',plural:'companies'}}
          renderItem={(item) => {
            item.key = item.DUNSNumber;

            const { DUNSNumber} = item;

            const title = item.OrganizationPrimaryName.OrganizationName.$ + " (" + item.DUNSNumber + ")"
            return (
              // @ts-ignore
              <ResourceList.Item
                key={item.DUNSNumber}
                onClick={() => this.props.remoteSearchGetDetails(item)}
                id={DUNSNumber}
              >

                <Card title={title} sectioned >
                <Stack>
                  <Card.Section title="Other">
                    <List type="bullet">
                      <List.Item>Status: { item.OperatingStatusText.$ }</List.Item>
                      { item.OrganizationIdentificationNumberDetail ?
                      <List.Item>{ item.OrganizationIdentificationNumberDetail["@TypeText"] + ": " +  item.OrganizationIdentificationNumberDetail.OrganizationIdentificationNumber }</List.Item> : null }
                    </List>
                  </Card.Section>
                  <Card.Section title="Address">
                    <List type="bullet">
                        { item.PrimaryAddress.StreetAddressLine ? item.PrimaryAddress.StreetAddressLine.map((e,index) =>
                          <List.Item key={index}>{e.LineText}</List.Item>) : null
                        }
                        { item.PrimaryAddress.PrimaryTownName != undefined ? <List.Item>{item.PrimaryAddress.PrimaryTownName}</List.Item> : null}
                        { item.PrimaryAddress.PostalCode != undefined ? <List.Item>{item.PrimaryAddress.PostalCode}</List.Item>  : null}
                        { item.PrimaryAddress.TerritoryOfficialName != undefined ? <List.Item>{item.PrimaryAddress.TerritoryOfficialName} </List.Item> : null}
                        { item.PrimaryAddress.CountryOfficialName != undefined ? <List.Item>{item.PrimaryAddress.CountryOfficialName }</List.Item>  : null}
                        { item.TelephoneNumber != undefined ? <List.Item>Tel: {item.TelephoneNumber.TelecommunicationNumber }</List.Item>  : null}
                        { item.FamilyTreeMemberRole != undefined && item.FamilyTreeMemberRole.FamilyTreeMemberRoleText != undefined ? <List.Item>Role: {item.FamilyTreeMemberRole.FamilyTreeMemberRoleText.$ }</List.Item>  : null}
                    </List>
                  </Card.Section>
                  </Stack>
                </Card>

              </ResourceList.Item>
            );
            }}
              />) : <p>No companies found</p> }
      </Card>
    )
    return (
      <Page fullWidth title="D&B Search">
        <Layout>
          <Layout.Section>{pageHeaderMarkup}</Layout.Section>
          <Layout.Section>{pageContentMarkup}</Layout.Section>
        </Layout>
      </Page>

    )
  }
}

const mapStateToProps = ({ dnbRemoteSearch }) => {
  return {
    dnbRemoteSearch
  };
};

export default connect(mapStateToProps,{remoteSearch, remoteSearchGetDetails},null, { areStatesEqual: (next, prev) => { return (shallowEqual(next,prev)) }})(DnbListApplication);



