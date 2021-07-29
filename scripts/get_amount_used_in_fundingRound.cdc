import CarbonHive from 0xf8d6e0586b0a20c7

// This script returns the cumulative impact amounts that have been
// minted for the specified funding round

// Parameters:
//
// projectID: The unique ID for the project
// fundingRoundID: The unique ID for the funding round

// Returns: UInt32
// cumulative amount associated to impacts with specified fundingRoundID minted for a project with specified projectID

pub fun main(projectID: UInt32, fundingRoundID: UInt32): UInt32 {

    let amount = CarbonHive.getAmountUsedInFundingRound(projectID: projectID, fundingRoundID: fundingRoundID)
        ?? panic("Could not find the specified funding round")

    return amount
}