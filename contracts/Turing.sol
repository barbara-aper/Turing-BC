// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Turing is ERC20 {

    address public owner;
    address public professor;

    mapping(string => address) public users;
    mapping(address => string) public users_reverse;
    string[] private codinomes;

    bool public voting;

    // votante => votado => ja votou?
    mapping(string => mapping(string => bool)) public hasVote;
    mapping(address => uint256) public votesCast;

    event UserUpdated(string codinome, address user_addr);
    event VotingStatusChanged(bool active);
    event TokenIssued(string codinome, address to, uint256 amount);
    event Voted(string from, string to, uint256 amount);
    event VoterBonus(string codinome, address to, uint256 amount);

    modifier onlyOwnerOrProfessor() {
        require(
            msg.sender == owner || msg.sender == professor,
            "apenas o owner ou a professora podem executar"
        );
        _;
    }

    constructor() ERC20("Turing", "Turing") {
        voting = true;
        owner = msg.sender;
        professor = 0x502542668aF09fa7aea52174b9965A7799343Df7;

        _setUser("roberta", 0x502542668aF09fa7aea52174b9965A7799343Df7);
        _setUser("nome1", 0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        _setUser("nome2", 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        _setUser("nome3", 0x90F79bf6EB2c4f870365E785982E1f101E93b906);
        _setUser("nome4", 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65);
        _setUser("nome5", 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc);
    }

    // turing e inteiro, sem casas decimais
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    // mantem users, users_reverse e a lista de codinomes sincronizados
    function _setUser(string memory codinome, address user_addr) internal {
        address old_addr = users[codinome];

        if (old_addr == address(0)) {
            codinomes.push(codinome);
        } else {
            delete users_reverse[old_addr];
        }

        users[codinome] = user_addr;
        users_reverse[user_addr] = codinome;
    }

    function updateUser(string memory codinome, address user_addr)
        public
        onlyOwnerOrProfessor
    {
        require(bytes(codinome).length > 0, "codinome nao pode ser vazio");
        require(user_addr != address(0), "endereco invalido");

        // endereco deve estar livre ou ja ser deste codinome
        require(
            bytes(users_reverse[user_addr]).length == 0 ||
                users[codinome] == user_addr,
            "endereco ja pertence a outro codinome"
        );

        _setUser(codinome, user_addr);
        emit UserUpdated(codinome, user_addr);
    }

    function votingOn() public onlyOwnerOrProfessor {
        voting = true;
        emit VotingStatusChanged(true);
    }

    function votingOff() public onlyOwnerOrProfessor {
        voting = false;
        emit VotingStatusChanged(false);
    }

    function issueToken(string memory codinome, uint256 qtde_de_Turings)
        public
        onlyOwnerOrProfessor
    {
        address to = users[codinome];
        require(to != address(0), "codinome nao cadastrado");
        require(qtde_de_Turings > 0, "quantidade deve ser maior que 0");

        _mint(to, qtde_de_Turings);
        emit TokenIssued(codinome, to, qtde_de_Turings);
    }

    function vote(string memory codinome, uint256 qtde_de_Turings) public {
        require(voting, "votacao nao esta ativa");

        string memory voter = users_reverse[msg.sender];
        require(bytes(voter).length > 0, "usuario nao autorizado");

        address to = users[codinome];
        require(to != address(0), "codinome nao cadastrado");
        require(to != msg.sender, "nao pode votar em si mesmo");
        require(
            qtde_de_Turings > 0 && qtde_de_Turings <= 2,
            "quantidade deve ser 1 ou 2"
        );
        require(!hasVote[voter][codinome], "voce ja votou neste codinome");

        hasVote[voter][codinome] = true;
        votesCast[msg.sender] += 1;

        _mint(to, qtde_de_Turings);
        emit Voted(voter, codinome, qtde_de_Turings);

        // bonus: a cada 10 votos, o votante ganha 1 turing
        if (votesCast[msg.sender] % 10 == 0) {
            _mint(msg.sender, 1);
            emit VoterBonus(voter, msg.sender, 1);
        }
    }

    // usado pelo frontend para montar o ranking
    function getCodinomes() public view returns (string[] memory) {
        return codinomes;
    }
}
