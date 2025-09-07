/**
 * Util methods
 */
const CUSTOM_PART = "--c";
const DOWNLOAD_PART ="/sfc/servlet.shepherd/document/download/";
  //".documentforce.com/sfc/servlet.shepherd/document/download/";

// Returns either an empty string or the org's base video download url
export function getBaseVideoUrl(baseUrl) {
  if (baseUrl) {
    const domain = baseUrl;//baseUrl.split(".")[0]; // `${domain}${CUSTOM_PART}${DOWNLOAD_PART}`;
    return "https://fivetoflow--partmar24.sandbox.my.site.com/f2fapp/sfc/servlet.shepherd/document/download/"; 
  }
  return "";
}