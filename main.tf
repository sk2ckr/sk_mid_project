module "accepter" {
    source  = "./accepter"
    
    PEER_ID = module.requester.peering_id
}

module "requester" {
    source  = "./requester"
}
