pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface RegistryAPI {
    function latestVault(address token) external view returns (address);

    function nextDeployment(address token) external view returns (uint256);

    function vaults(address token, uint256 deploymentId)
        external
        view
        returns (address);

    function governance() external view returns (address);
}

interface VaultAPI {
    function token() external view returns (address);

    function strategies(address _strategy)
        external
        view
        returns (StrategyParams memory);
}

import {
    StrategyParams,
    StrategyAPI
} from "@yearnvaults/contracts/BaseStrategy.sol";

contract GuestList {
    RegistryAPI public registry;
    mapping(address => bool) public guests;
    VaultAPI[] private _cachedVaults;

    constructor(address _registry) public {
        registry = RegistryAPI(_registry);
    }

    function authorized(address _guest, uint256 _amount)
        public
        view
        returns (bool)
    {
        if (guests[_guest] == true) {
            return true;
        } else if (guests[_guest] != true) {
            return isValidStrategy(_guest);
        }
        return false;
    }

    function isValidStrategy(address _guest) private view returns (bool) {
        VaultAPI vault = VaultAPI(StrategyAPI(_guest).vault());
        if (vault.strategies(_guest).activation == 0) {
            return false;
        }
        return isVaultInRegistry(vault);
    }

    function isVaultInRegistry(VaultAPI vault) private view returns (bool) {
        address token = vault.token();
        uint256 num_deployments = registry.nextDeployment(token);
        VaultAPI[] memory vaults = allVaults(token);
        for (uint256 v = 0; v < vaults.length; v++) {
            if (vaults[v] == vault) {
                return true;
            }
        }
        return false;
    }

    function allVaults(address token) public view returns (VaultAPI[] memory) {
        uint256 cache_length = _cachedVaults.length;

        uint256 num_deployments = registry.nextDeployment(token);

        // Use cached
        if (cache_length == num_deployments) {
            return _cachedVaults;
        }

        VaultAPI[] memory vaults = new VaultAPI[](num_deployments);
        for (
            uint256 deployment_id = 0;
            deployment_id < cache_length;
            deployment_id++
        ) {
            vaults[deployment_id] = _cachedVaults[deployment_id];
        }

        for (
            uint256 deployment_id = cache_length;
            deployment_id < num_deployments;
            deployment_id++
        ) {
            vaults[deployment_id] = VaultAPI(
                registry.vaults(token, deployment_id)
            );
        }

        return vaults;
    }

    function updateVaultCache(address token) public {
        require(msg.sender == registry.governance());
        VaultAPI[] memory vaults = allVaults(token);

        if (vaults.length > _cachedVaults.length) {
            _cachedVaults = vaults;
        }
    }

    function inviteGuest(address guest) public {
        require(msg.sender == registry.governance());

        require(!guests[guest]);
        guests[guest] = true;
    }

    function revokeGuest(address guest) public {
        require(msg.sender == registry.governance());

        guests[guest] = false;
    }
}
