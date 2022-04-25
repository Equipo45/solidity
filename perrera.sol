pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract perrera{

    address public owner;
    address public contracctAddress;

    constructor(){
        owner = msg.sender;
        contracctAddress = address(this);
    }

    struct usuario{
        string nombre;
        uint id;
    }

    struct perro{
        string nombre;
        string raza;
        uint id;
        uint peso;
    }

    mapping(address => usuario) dirrecionDatosU;
    mapping(address => bool) suscripcionActiva;
    mapping(address => bytes32) usuarioPerro;
    mapping(bytes32 => perro) hashPerro;

    event persona_suscrita(bool);
    event perroAceptado(bool);

    
    modifier soloPerrera(address _dir){
        require(_dir == owner, "La dirrecion tiene que ser igual a la del jefe");
        _;
    }
    modifier soloUsuarioSuscrito(address _dir){
        require(suscripcionActiva[_dir]==true,"Tu suscripcion no esta activa");
        _;
    }

    function suscribirsePerrera(string memory _nombre,uint _id,uint _precio)public{
        require(_precio >= 50 ,"No cumple el precio minimo");
        dirrecionDatosU[msg.sender]=usuario(_nombre,_id);
        suscripcionActiva[msg.sender]=true;
        emit persona_suscrita(true);
    }
    function verDatos()public view returns(string memory){
        return dirrecionDatosU[msg.sender].nombre;
    }
    function  suscribirPerro(string memory _nombre,string memory _raza, uint _id,uint _peso)public soloUsuarioSuscrito(msg.sender){
        bytes32 hash = keccak256(abi.encodePacked(_id));
        hashPerro[hash]=perro(_nombre,_raza,_id,_peso);
        usuarioPerro[msg.sender]=hash;

        emit perroAceptado(true);

    }

    function verDatos(uint _idPerro)public view soloUsuarioSuscrito(msg.sender) returns(string memory){
        bytes32 hash = usuarioPerro[msg.sender];
        return hashPerro[hash].nombre;
    }



}