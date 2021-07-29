import CarbonHive from 0xf8d6e0586b0a20c7

// This is the script to get a list of all the impacts' ids an account owns

// Parameters:
// account: The Flow Address of the account whose impact data will be read

// Returns: [UInt64]
// list of all impacts' ids an account owns

pub fun main(account: Address): [UInt64] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(/public/ImpactCollection)
                            .borrow<&{CarbonHive.ImpactCollectionPublic}>()!

    log(collectionRef.getIDs())

    return collectionRef.getIDs()
}