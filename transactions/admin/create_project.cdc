import CarbonHive from 0xf8d6e0586b0a20c7

// This transaction is for the admin to create a new project resource
// and store it in the carbonhive smart contract

transaction(
    name: String, 
    description: String, 
    projectOwner: String, 
    projectType: String, 
    location: String, 
    gis: String, 
    metadata: {String: String}
) {
    
    let adminRef: &CarbonHive.ProjectAdmin
    let currProjectID: UInt32

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.ProjectAdmin>(from: /storage/CarbonHiveAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currProjectID = CarbonHive.nextProjectID;
    }

    execute {
        // Create a project with the specified metadata
        self.adminRef.createProject(
            name: name,
            description: description,
            projectOwner: projectOwner,
            projectType: projectType,
            location: location,
            gis: gis,
            metadata: metadata
        )
    }

    post {
        CarbonHive.getProjectData(projectID: self.currProjectID) != nil:
            "projectID doesnt exist"
 
    }
}