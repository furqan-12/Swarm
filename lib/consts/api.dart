const baseUrl = "https://api-get-swarm.com";
const apiBaseUrl = baseUrl + "/api";
const apiImageBaseUrl = baseUrl + "/";
const signalRUrl = baseUrl;
const tenant = "root";
const PhotographerType = "Photographer";
const ModelType = "Customer";
const BrandType = "Brand";
const PhotographerTypeId = "22b8b561-7cc9-4201-9461-dd9c8c51aabb";
const ModelTypeId = "846dd768-315c-4b76-b6a4-ed7a79873c6c";
const BrandTypeId = "12fc2765-6b28-4f1e-8489-589ee5d08cab";

const Map<String, dynamic> Experiences = {
  'Starter': 'fd7684ad-4232-4f76-aaab-1cf51eabbc39',
  'Experienced': 'a6ade61f-38b3-441a-b7b3-bb717b6b66e2',
  'Pro': '8b8cfa87-9ad1-4545-abfb-42293d331ba4',
};

const Map<String, String> VideoExperiences = {
  'fd7684ad-4232-4f76-aaab-1cf51eabbc39': "[2] 3-min",
  'a6ade61f-38b3-441a-b7b3-bb717b6b66e2': "[3] 3-min",
  '8b8cfa87-9ad1-4545-abfb-42293d331ba4': "[1] 10-min",
};

const Map<String, int> ExperienceTabIndex = {
  '': 0,
  'fd7684ad-4232-4f76-aaab-1cf51eabbc39': 1,
  'a6ade61f-38b3-441a-b7b3-bb717b6b66e2': 2,
  '8b8cfa87-9ad1-4545-abfb-42293d331ba4': 3,
};

const Map<String, String> ExperienceName = {
  'fd7684ad-4232-4f76-aaab-1cf51eabbc39': 'Sta',
  'a6ade61f-38b3-441a-b7b3-bb717b6b66e2': 'Exp',
  '8b8cfa87-9ad1-4545-abfb-42293d331ba4': 'Pro',
};

const Map<String, String> ShootingDevice = {
  'Phone': 'b50effd1-5201-4db5-bdf2-707543bfd796',
  'Camera': 'b03700e6-4d07-4d66-be48-3d19abb59cf3',
  'Other': 'b50effd1-5201-4db5-bdf2-707543BFD799',
};

const Map<String, String> Skills = {
  'Photography': '0B1C6E42-6A64-45E6-A9B7-82B8BAA8D3C7',
  'Videography': '1D585F7B-4AB0-4AED-8704-FE3B4FBE8E07',
  'Both': 'E1874A28-5064-4D54-88D8-59D1D6A9B00F'
};

const Map<String, String> ShootingTypes = {
  'Video': '2dc9af6e-242e-4937-951f-a9d110f7086f',
};
