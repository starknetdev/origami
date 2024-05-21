use starknet::{ContractAddress, ClassHash};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IERC721EnumerablePreset<TState> {
    // IERC721
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn token_uri(ref self: TState, token_id: u256) -> ByteArray;
    fn owner_of(self: @TState, account: ContractAddress) -> bool;
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);

    // IERC721CamelOnly
    fn tokenURI(ref self: TState, token_id: u256) -> ByteArray;

    // IWorldProvider
    fn world(self: @TState,) -> IWorldDispatcher;

    fn initializer(ref self: TState, name: ByteArray, symbol: ByteArray, base_uri: ByteArray);
    fn enum_transfer_from(
        ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn enum_safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
}

#[starknet::interface]
trait IERC721EnumerableInit<TState> {
    fn initializer(ref self: TState, name: ByteArray, symbol: ByteArray, base_uri: ByteArray);
}

#[starknet::interface]
trait IERC721EnumerableTransfer<TState> {
    fn enum_transfer_from(
        ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn enum_safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
}

#[dojo::contract(allow_ref_self)]
mod ERC721Enumerable {
    use starknet::ContractAddress;
    use starknet::{get_contract_address, get_caller_address};

    use token::components::token::erc721::erc721_approval::erc721_approval_component;
    use token::components::token::erc721::erc721_balance::erc721_balance_component;
    use token::components::token::erc721::erc721_enumerable::erc721_enumerable_component;
    use token::components::token::erc721::erc721_metadata::erc721_metadata_component;
    use token::components::token::erc721::erc721_owner::erc721_owner_component;

    component!(
        path: erc721_approval_component, storage: erc721_approval, event: ERC721ApprovalEvent
    );
    component!(path: erc721_balance_component, storage: erc721_balance, event: ERC721BalanceEvent);
    component!(
        path: erc721_enumerable_component, storage: erc721_enumerable, event: ERC721EnumerableEvent
    );
    component!(
        path: erc721_metadata_component, storage: erc721_metadata, event: ERC721MetadataEvent
    );
    component!(path: erc721_owner_component, storage: erc721_owner, event: ERC721OwnerEvent);

    #[abi(embed_v0)]
    impl ERC721ApprovalImpl =
        erc721_approval_component::ERC721ApprovalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721ApprovalCamelImpl =
        erc721_approval_component::ERC721ApprovalCamelImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721BalanceImpl =
        erc721_balance_component::ERC721BalanceImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721BalanceCamelImpl =
        erc721_balance_component::ERC721BalanceCamelImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721EnumerableImpl =
        erc721_enumerable_component::ERC721EnumerableImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721EnumerableCamelImpl =
        erc721_enumerable_component::ERC721EnumerableCamelImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721MetadataImpl =
        erc721_metadata_component::ERC721MetadataImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721MetadataCamelImpl =
        erc721_metadata_component::ERC721MetadataCamelImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721OwnerImpl = erc721_owner_component::ERC721OwnerImpl<ContractState>;

    impl ERC721ApprovalInternalImpl = erc721_approval_component::InternalImpl<ContractState>;
    impl ERC721BalanceInternalImpl = erc721_balance_component::InternalImpl<ContractState>;
    impl ERC721EnumerableInternalImpl = erc721_enumerable_component::InternalImpl<ContractState>;
    impl ERC721MetadataInternalImpl = erc721_mintable_component::InternalImpl<ContractState>;
    impl ERC721OwnerInternalImpl = erc721_owner_component::InternalImpl<ContractState>;

    mod Errors {
        const INVALID_ACCOUNT: felt252 = 'ERC721: invalid account';
        const UNAUTHORIZED: felt252 = 'ERC721: unauthorized caller';
        const INVALID_RECEIVER: felt252 = 'ERC721: invalid receiver';
        const WRONG_SENDER: felt252 = 'ERC721: wrong sender';
        const SAFE_TRANSFER_FAILED: felt252 = 'ERC721: safe transfer failed';
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721_approval: erc721_approval_component::Storage,
        #[substorage(v0)]
        erc721_balance: erc721_balance_component::Storage,
        #[substorage(v0)]
        erc721_enumerable: erc721_enumerable_component::Storage,
        #[substorage(v0)]
        erc721_metadata: erc721_metadata_component::Storage,
        #[substorage(v0)]
        erc721_owner: erc721_owner_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ERC721ApprovalEvent: erc721_approval_component::Event,
        ERC721BalanceEvent: erc721_balance_component::Event,
        ERC721EnumerableEvent: erc721_enumerable_component::Event,
        ERC721MetadataEvent: erc721_metadata_component::Event,
        ERC721OwnerEvent: erc721_owner_component::Event,
    }

    #[abi(embed_v0)]
    impl ERC721InitializerImpl of super::IERC721EnumerableInit<ContractState> {
        fn initializer(
            ref self: ContractState, name: ByteArray, symbol: ByteArray, base_uri: ByteArray,
        ) {
            self.erc721_metadata.initializer(name, symbol, base_uri);
        }
    }

    #[abi(embed_v0)]
    impl ERC721TransferImpl of super::IERC721EnumerableTransfer<ContractState> {
        fn enum_transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            assert(
                self.erc721_approval.is_approved_or_owner(get_caller_address(), token_id),
                Errors::UNAUTHORIZED
            );
            self.erc721_balance.transfer_internal(from, to, token_id);
            self.erc721_enumerable.remove_token_from_owner_enumeration(from, token_id);
            self.erc721_enumerable.add_token_to_owner_enumeration(to, token_id);
        }

        fn enum_safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            assert(
                self.erc721_approval.is_approved_or_owner(get_caller_address(), token_id),
                Errors::UNAUTHORIZED
            );
            self.erc721_balance.safe_transfer_internal(from, to, token_id, data);
            self.erc721_enumerable.remove_token_from_owner_enumeration(from, token_id);
            self.erc721_enumerable.add_token_to_owner_enumeration(to, token_id);
        }
    }
}
