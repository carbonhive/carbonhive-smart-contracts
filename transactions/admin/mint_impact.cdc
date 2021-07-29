import CarbonHive from 0xf8d6e0586b0a20c7


transaction(
    recipientAddr: Address,
    projectID: UInt32, 
    fundingRoundID: UInt32,
    amount: UInt32,
    location: String,
    locationDescriptor: String,
    vintagePeriod: String,
    contentData: String,
    contentType: String
) {
    // local variable for the admin reference
    let adminRef: &CarbonHive.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&CarbonHive.Admin>(from: /storage/CarbonHiveAdmin)!
    }

    execute {
        let projectRef = self.adminRef.borrowProject(projectID: projectID)

        let content <- self.adminRef.createContent(
            data: contentData,
            contentType: contentType
        )

        // Mint a new NFT
        let impact <- projectRef.mintImpact(
                                    fundingRoundID: fundingRoundID,
                                    amount: amount, 
                                    location: location,
                                    locationDescriptor: locationDescriptor,
                                    vintagePeriod: vintagePeriod,
                                    content: <- content
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
