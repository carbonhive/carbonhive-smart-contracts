import CarbonHive from 0xf8d6e0586b0a20c7

// This transaction sets up an account to use CarbonHive
// by storing an empty moment collection and creating
// a public capability for it

transaction {

    prepare(acct: AuthAccount) {

        // First, check to see if a moment collection already exists
        if acct.borrow<&CarbonHive.Collection>(from: /storage/ImpactCollection) == nil {

            // create a new CarbonHive Collection
            let collection <- CarbonHive.createEmptyCollection() as! @CarbonHive.Collection

            // Put the new Collection in storage
            acct.save(<-collection, to: /storage/ImpactCollection)

            // create a public capability for the collection
            acct.link<&{CarbonHive.ImpactCollectionPublic}>(/public/ImpactCollection, target: /storage/ImpactCollection)
        }
    }
}