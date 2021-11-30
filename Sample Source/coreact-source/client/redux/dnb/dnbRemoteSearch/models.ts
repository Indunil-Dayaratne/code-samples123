export interface TransactionDetail {
  ApplicationTransactionID: string;
  ServiceTransactionID: string;
  TransactionTimestamp: Date;
}

export interface TransactionResult {
  SeverityText: string;
  ResultID: string;
  ResultText: string;
}

export interface OrganizationName {
  $: string;
}

export interface OrganizationPrimaryName {
  OrganizationName: OrganizationName;
}

export interface StreetAddressLine {
  LineText: string;
}

export interface GeographicalPrecisionText {
  DNBCodeValue: number;
  $: string;
}

export interface PrimaryAddress {
  StreetAddressLine: StreetAddressLine[];
  PrimaryTownName: string;
  CountryISOAlpha2Code: string;
  PostalCode: string;
  TerritoryOfficialName: string;
  CountryOfficialName: string;
  GeographicalPrecisionText: GeographicalPrecisionText;
  LatitudeMeasurement?: number;
  LongitudeMeasurement?: number;
  PostalCodeExtensionCode: string;
  TerritoryAbbreviatedName: string;
  MetropolitanStatisticalAreaUSCensusCode: string[];
}

export interface StreetAddressLine2 {
  LineText: string;
}

export interface MailingAddress {
  StreetAddressLine: StreetAddressLine2[];
  PrimaryTownName: string;
  CountryISOAlpha2Code: string;
  PostalCode: string;
  TerritoryOfficialName: string;
  CountryOfficialName: string;
}

export interface TelephoneNumber {
  TelecommunicationNumber: string;
}

export interface FamilyTreeMemberRoleText {
  DNBCodeValue: number;
  $: string;
}

export interface FamilyTreeMemberRole {
  FamilyTreeMemberRoleText: FamilyTreeMemberRoleText;
}

export interface ConsolidatedEmployeeDetails {
  TotalEmployeeQuantity: number;
}

export interface SalesRevenueAmount {
  CurrencyISOAlpha3Code: string;
  UnitOfSize: string;
  $: number;
}

export interface FacsimileNumber {
  TelecommunicationNumber: string;
}

export interface OrganizationName2 {
  $: string;
}

export interface TradeStyleName {
  OrganizationName: OrganizationName2;
}

export interface FindCandidate {
  DUNSNumber: string;
  OrganizationPrimaryName: OrganizationPrimaryName;
  PrimaryAddress: PrimaryAddress;
  MailingAddress: MailingAddress;
  TelephoneNumber: TelephoneNumber;
  FamilyTreeMemberRole: FamilyTreeMemberRole[];
  StandaloneOrganizationIndicator: boolean;
  ConsolidatedEmployeeDetails: ConsolidatedEmployeeDetails;
  SalesRevenueAmount: SalesRevenueAmount;
  DisplaySequence: number;
  FacsimileNumber: FacsimileNumber;
  TradeStyleName: TradeStyleName[];
  ManufacturingIndicator?: boolean;
}

export interface FindCompanyResponseDetail {
  CandidateMatchedQuantity: number;
  CandidateReturnedQuantity: number;
  FindCandidate: FindCandidate[];
}

export interface FindCompanyResponse {
  ServiceVersionNumber: string;
  TransactionDetail: TransactionDetail;
  TransactionResult: TransactionResult;
  FindCompanyResponseDetail: FindCompanyResponseDetail;
}

