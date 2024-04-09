use starknet::ContractAddress;

///
/// Model
///

#[derive(Model, Copy, Drop, Serde)]
struct ERC721OwnerModel {
    #[key]
    token: ContractAddress,
    #[key]
    token_id: u128,
    address: ContractAddress,
}

///
/// Interface
///

#[starknet::interface]
trait IERC721Owner<TState> {
    fn owner_of(self: @TState, token_id: u128) -> ContractAddress;
}

#[starknet::interface]
trait IERC721OwnerCamel<TState> {
    fn ownerOf(self: @TState, token_id: u128) -> ContractAddress;
}

///
/// ERC20Balance Component
///
#[starknet::component]
mod erc721_owner_component {
    use super::ERC721OwnerModel;
    use super::IERC721Owner;
    use super::IERC721OwnerCamel;

    use starknet::ContractAddress;
    use starknet::{get_contract_address, get_caller_address};
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };

    use token::components::token::erc721::erc721_approval::erc721_approval_component as erc721_approval_comp;
    use erc721_approval_comp::InternalImpl as ERC721ApprovalInternal;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Copy, Drop, Serde, starknet::Event)]
    enum Event {
        Transfer: Transfer
    }

    #[derive(Copy, Drop, Serde, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256
    }

    #[embeddable_as(ERC721OwnerImpl)]
    impl ERC721Owner<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of IERC721Owner<ComponentState<TContractState>> {
        fn owner_of(self: @ComponentState<TContractState>, token_id: u128) -> ContractAddress {
            self.get_owner(token_id).address
        }
    }

    #[embeddable_as(ERC721OwnerCamelImpl)]
    impl ERC721OwnerCamel<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of IERC721OwnerCamel<ComponentState<TContractState>> {
        fn ownerOf(self: @ComponentState<TContractState>, token_id: u128) -> ContractAddress {
            self.get_owner(token_id).address
        }
    }


    #[generate_trait]
    impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        fn get_owner(
            self: @ComponentState<TContractState>, token_id: u128
        ) -> ERC721OwnerModel {
            get!(
                self.get_contract().world(), (token_id), (ERC721OwnerModel)
            )
        }

        fn set_owner(
            ref self: ComponentState<TContractState>,
            token_id: u128,
            address: ContractAddress
        ) {
            set!(self.get_contract().world(), ERC721OwnerModel { token: get_contract_address(), token_id, address });
        }

        fn exists(self: @ComponentState<TContractState>, token_id: u128) -> bool {
            let owner = self.get_owner(token_id).address;
            owner.is_non_zero()
        }
    }
}