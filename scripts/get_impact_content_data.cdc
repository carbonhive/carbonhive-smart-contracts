import CarbonHive from 0xf8d6e0586b0a20c7

// This script gets the content data from an impact
// in a collection by getting a reference to the impact NFT

// Parameters:
//
// account: The Flow Address of the account who owns the impact
// id: The unique ID for the impact

// Returns: String

pub fun main(account: Address, id: UInt64): String {

    // borrow a public reference to the owner's impact collection 
    let collectionRef = getAccount(account).getCapability(/public/ImpactCollection)
        .borrow<&{CarbonHive.ImpactCollectionPublic}>()
        ?? panic("Could not get public impact collection reference")

    // borrow a reference to the specified impact in the collection
    let token = collectionRef.borrowImpact(id: id)
        ?? panic("Could not borrow a reference to the specified impact")

    return token.getContentData()
}