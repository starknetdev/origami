use starknet::{ContractAddress, ClassHash};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IERC721BalanceMock<TState> {
    // IERC721
    fn owner_of(self: @TState, account: ContractAddress) -> bool;
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn get_approved(self: @TState, token_id: u128) -> ContractAddress;
    fn transfer_from(
        ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u128
    );
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);

    // IERC721CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(
        ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u128
    );

    // IWorldProvider
    fn world(self: @TState,) -> IWorldDispatcher;

    fn initializer(ref self: TState, recipient: ContractAddress,);
}

#[dojo::contract]
mod erc721_balance_mock {
    use starknet::ContractAddress;
    use token::components::token::erc721::erc721_approval::erc721_approval_component;
    use token::components::token::erc721::erc721_balance::erc721_balance_component;

    component!(
        path: erc721_approval_component, storage: erc721_approval, event: ERC721ApprovalEvent
    );
    component!(path: erc721_balance_component, storage: erc721_balance, event: ERC721BalanceEvent);

    #[abi(embed_v0)]
    impl ERC721ApprovalImpl =
        erc721_approval_component::ERC721ApprovalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721BalanceImpl =
        erc721_balance_component::ERC721BalanceImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721BalanceCamelImpl =
        erc721_balance_component::ERC721BalanceCamelImpl<ContractState>;

    impl ERC721ApprovalInternalImpl = erc721_approval_component::InternalImpl<ContractState>;
    impl ERC721BalanceInternalImpl = erc721_balance_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721_approval: erc721_approval_component::Storage,
        #[substorage(v0)]
        erc721_balance: erc721_balance_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ERC721ApprovalEvent: erc721_approval_component::Event,
        ERC721BalanceEvent: erc721_balance_component::Event,
    }
}
