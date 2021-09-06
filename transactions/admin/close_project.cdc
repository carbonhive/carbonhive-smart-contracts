import CarbonHive from 0xf8d6e0586b0a20c7

// This transaction is for the admin to close a Project
// When a Project is closed, no more Funding Round can be added, but 
// Impacts still can be minted from a Project, and 
// new Reports still can be added

transaction(
    projectId: UInt32
) {
    
    let adminRef: &CarbonHive.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.Admin>(from: /storage/CarbonHiveAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
    }

    execute {
        let projectRef = self.adminRef.borrowProject(projectID: projectId)
        projectRef.close()
    }

    post {
        self.adminRef.borrowProject(projectID: projectId).closed == true:
            "Failed closing project"
    }
}