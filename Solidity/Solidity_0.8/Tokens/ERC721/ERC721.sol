// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}


interface IERC721Receiver {
    function onERC721Received( // This is called inside SafeTransferFrom() and when `to` address is a contract this should be called.
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll( address indexed owner, address indexed operator, bool approved);

    mapping(uint => address) internal _ownerOf; // token_id -> owner address
    mapping(address => uint) internal _balanceOf; // owner address -> token amount
    mapping(uint => address) internal _approvals; // nft_id -> Bob address
    mapping(address => mapping(address => bool)) public isApprovedForAll; // owner -> addressOperator that the owner gave permission to spend this nft
    

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    // FUNCTION IMPLEMENTATION FROM THE INTERFACE BELLOW

    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "Owner = zero address");
        return _balanceOf[owner];
    }


    function ownerOf(uint256 tokenId) external view returns (address owner) {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "owner = zero address");
    }

    function setApprovalForAll(address operator, bool _approved) external {
        isApprovedForAll[msg.sender][operator] = _approved; 
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = _ownerOf[tokenId];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "not authorized");

        _approvals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address operator) {
        require(_approvals[tokenId] != address(0), "token doesn't exist");
        return _approvals[tokenId];
    }

    function _isApprovedOrOwner( // ----> This is more like util function to reuse accross others
        address owner,
        address spender,
        uint tokenId
    ) internal view returns (bool) {
        return (
            spender == owner || 
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]
        );
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "to = zero address");
        require(_isApprovedOrOwner(from, msg.sender, tokenId), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        delete _approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);

        require(to.code.length == 0 || // If length is 0 means that `to` address is either not a contract or it is a contract that was just deployed in this transaction
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "") == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );

    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external {
        transferFrom(from, to, tokenId);

        require(to.code.length == 0 || // If length is 0 means that `to` address is either not a contract or it is a contract that was just deployed in this transaction
            IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) == IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "to = zero address");
        require(_ownerOf[tokenId] == address(0), "token exist");
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;
        emit Transfer(msg.sender, to, tokenId);
    }
    
    function _burn(uint tokenId) internal {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "token doesn't exist");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];
        emit Transfer(owner, address(this), tokenId);
    }
}

contract MyNft is ERC721 {
    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}