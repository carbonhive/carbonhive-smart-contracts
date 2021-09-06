import CarbonHive from 0xf8d6e0586b0a20c7


pub fun main(fundingRoundID: UInt32): CarbonHive.FundingRoundData? {

    let fundingRoundData = CarbonHive.getFundingRoundData(fundingRoundID: fundingRoundID) ?? panic("Funding Round doesn't exist")

    log(fundingRoundData)

    return fundingRoundData
}