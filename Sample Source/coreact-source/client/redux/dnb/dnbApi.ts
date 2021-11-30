import axios from 'axios'
import * as constants from '../../constants/defaultValues'
import { access } from 'fs';
const  executeMethod = async(url: string,method: string ,headers : any, params: any) => {
  try
  {
    let result = await axios.request({
      url,
      method,
      headers,
      params,
      withCredentials: true,
    } )

    if(result.status === 200) {
      return result.data;
    }
    else
      throw "Request was not successful"
  } catch(error) {
      throw error;
  }
}

const executeMethodWithAccessToken = async(url: string,method: string, params: any,accessToken: string) => {
  try
  {
    let result = await axios.request({
      url,
      method,
      headers: {  "Content-Type": "application/json", "Authorization" : "Bearer " + accessToken },
      params,
      withCredentials: true
    })

    if(result.status === 200) {
      return result.data;
    }
    else
      throw "Request was not successful"
  } catch(error) {
      throw error;
  }
}

export const dnbApi = {

  async getRemoteSearch(keyword: string,countryCode: string,activeOnly: boolean, accessToken: string) {
    let url = constants.dnbBaseUrl + "/remotesearch/"+ keyword;

    return await executeMethodWithAccessToken(url,'get',{ countryCode: countryCode, activeOnly: activeOnly},accessToken);
  },

  async getXValueQuery(xValue: string, dunsNumber: string, accessToken: string) {
    let url = constants.dnbBaseUrl + "/query/"+ xValue + "/" + dunsNumber;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getCI(dunsNumber: string,accessToken: string) {

    let url = `https://direct.dnb.com/V6.1/organizations/${dunsNumber}/products/DCP_PREM`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getKYC(dunsNumber: string,accessToken: string) {

    let url = `https://direct.dnb.com/V6.0/organizations/${dunsNumber}/products/KYC`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getVerification(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V6.0/organizations/${dunsNumber}/products/CMP_VRF_RPT`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getOwnership(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V6.0/organizations/${dunsNumber}/products/SMPL_OWNSHP`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getCreditRating(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V5.0/organizations/${dunsNumber}/products/RTNG_TRND`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getPaymentRisk(dunsNumber: string,accessToken: string) {

    let url = `https://direct.dnb.com/V5.0/organizations/${dunsNumber}/products/PBPR_ENH`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getLegalSuits(dunsNumber: string,accessToken: string) {

    let url = `https://direct.dnb.com/V3.0/organizations/${dunsNumber}/products/PUBREC_SUITS`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getLegalJudgements(dunsNumber: string,accessToken: string) {

    let url = `https://direct.dnb.com/V3.0/organizations/${dunsNumber}/products/PUBREC_JDG`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getLegalBankruptcy(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V3.0/organizations/${dunsNumber}/products/PUBREC_DTLS`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getMinorityLinkage(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V4.0/organizations/${dunsNumber}/products/LNK_FF_MNRT`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },

  async getCorporateLinkage(dunsNumber: string,accessToken: string) {
    let url = `https://direct.dnb.com/V4.0/organizations/${dunsNumber}/products/LNK_FF?AttachCompressedProductIndicator=true`;

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  },
  async getIdentity(subjectName: string,countryCode: string, activeOnly: boolean,accessToken: string) {
    let url = `https://direct.dnb.com/V6.0/organizations?subjectName=${subjectName}&CountryISOAlpha2Code=${countryCode}&match=true&cleansematch=true`;

    if(activeOnly === true)
      url += "&ExclusionCriteria-1=Exclude Out of Business";

    return await executeMethodWithAccessToken(url,'get',null,accessToken);
  }
}

