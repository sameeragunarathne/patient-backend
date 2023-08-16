import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
isolated service / on new http:Listener(9090) {

    private json patientTemplate = {
        resourceType: "Patient",
        id: (),
        meta: {
            profile: [
                "http://hl7.org.au/fhir/StructureDefinition/au-patient"
            ]
        },
        name: [
            {
                use: "official",
                given: [()],
                family: ()
            }
        ],
        birthDate: (),
        managingOrganization: {
            reference: ()
        }
    };

    private map<PatientData> patientDataMap = {
        "1": {
            id: "1",
            firstName: "Brian",
            lastName: "Cox",
            birthDate: "2009-01-01",
            managingOrganization: "Organization/1"
        },
        "2": {
            id: "2",
            firstName: "marie",
            lastName: "page",
            birthDate: "2009-10-01",
            managingOrganization: "Organization/2"
        },
        "3": {
            id: "3",
            firstName: "vijay",
            lastName: "kumar",
            birthDate: "2009-10-01",
            managingOrganization: "Organization/1"
        }
    };

    isolated resource function get [string fhirType](string searchParams = "") returns json[]|error {
        lock {
            map<json>[] jsonArr = [];
            foreach var item in self.patientDataMap {
                map<json> patientResponse = <map<json>>self.patientTemplate.clone();
                patientResponse["id"] = item.id;
                patientResponse["name"] = {
                    use: "official",
                    given: [item.firstName],
                    family: item.lastName
                };
                patientResponse["birthDate"] = item.birthDate;
                patientResponse["managingOrganization"] = {
                    reference: item.managingOrganization
                };
                jsonArr.push(patientResponse.clone());
            }
            return jsonArr.clone();
        }
    }

    isolated resource function get [string fhirType]/[string id]() returns json|error {
        lock {
            PatientData? data = self.patientDataMap[id];
            if data is PatientData {
                map<json> patientResponse = <map<json>>self.patientTemplate.clone();
                patientResponse["id"] = data.id;
                patientResponse["name"] = {
                    use: "official",
                    given: [data.firstName],
                    family: data.lastName
                };
                patientResponse["birthDate"] = data.birthDate;
                patientResponse["managingOrganization"] = {
                    reference: data.managingOrganization
                };
                return patientResponse.clone();
            }
        }
        return {
            resourceType: "OperationOutcome",
            issue: [
                {
                    severity: "error",
                    code: "not-found",
                    details: {
                        text: "The requested resource was not found"
                    }
                }
            ]
        };
    }

    isolated resource function post [string fhirType]() returns json|error {

        return {
            resourceType: "OperationOutcome",
            issue: [
                {
                    severity: "error",
                    code: "not-implemented",
                    details: {
                        text: "This operation has not been implemented"
                    }
                }
            ]
        };
    }
}

type PatientData record {|
    string id;
    string firstName;
    string lastName;
    string birthDate;
    string managingOrganization;
|};
