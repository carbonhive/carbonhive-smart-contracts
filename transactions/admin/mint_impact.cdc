import CarbonHive from 0xf8d6e0586b0a20c7


transaction(
    recipientAddr: Address,
    projectID: UInt32, 
    fundingRoundID: UInt32,
    amount: UInt32,
    gis: String,
    timePeriod: String
) {
    // local variable for the admin reference
    let adminRef: &CarbonHive.ProjectAdmin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.ProjectAdmin>(from: /storage/CarbonHiveAdmin)!
    }

    execute {
        let projectRef = self.adminRef.borrowProject(projectID: projectID)

        // Mint a new NFT
        let impact <- projectRef.mintImpact(
                                    fundingRoundID: fundingRoundID,
                                    amount: amount, 
                                    gis: gis,
                                    timePeriod: timePeriod
                                )
        let recipient = getAccount(recipientAddr)
        if recipient == nil { panic("Recipient doesn't exist") }

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/ImpactCollection).borrow<&{CarbonHive.ImpactCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's impact collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-impact)
    }
}