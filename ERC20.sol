// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//10 0xc5559f7319c2FeC475F1312E0E99104814E54F54
//190 0x4C3dF599fa5035a2525bD5aecf9fdfa52F665E38
//contrato 0x7ccDb0B1f3e149882BDC90E6524E66b3373a1654

interface IERC20{
    //cantidad de tokens
    function totalSupply()external view returns(uint256);
    //cantidad de tokens en la cartera de la dirrecion
    //External fuera de la funcion
    function balanceOf(address _dir) external view returns(uint256);

    //Permite gastar tokens de otra cartera
    function allowence(address _owner,address _spender) external view returns(uint256);

    //Hacer trasnferencia
    //Calidad tranferencia
    function transfer(address _recipient,uint _quantity) external  returns(bool);
    function transfer_disney(address _spender,address _recipient, uint _quantity)external returns(bool);
    //Devuelve aprobacion de transferencia
    //valida poder gastar los tokens
    function approve(address _spender, uint _quantity) external  returns(bool);

    //Devuelve un valor boleano
    function transferFrom(address _spender,address _recipient,uint256 quantity)external  returns(bool);


    //indexed refleja la dirrecion del token que se ha mandado en el log
    //de tal amnera que a la hora de buscarlo sea mas sencillo tanto para el sistema
    //como para el publico

    //Eventos para hacer publicas las tranferencias 
    //De donde a donde y cuanto
    event Transfer(address indexed from ,address indexed to, uint256 _quantity);

    //Evento que se debe emitir cuando se permite gastar tokens con el metodo allowence
    //cartera x tiene permitido gastar y tokens de la cartera z

    event Approval(address indexed owner,address indexed spender,uint256 _quantity);

}

contract ERC20Basic is IERC20{

    string public constant name = "Disney";
    string public constant symbol = "DS";
    //Decimales que pdora tener el token
    uint8 public constant decimals = 2;

    mapping (address => uint) dirrecion_Tokens;
    //Una dirrecion permite  aotra dirrecion x tokens
    //Los mino yo y los distribuyo a otros
    mapping(address => mapping(address => uint)) allowed;

    //Cuando llege a 0 no podemos repartir mas
    uint256 total_supply_;

    constructor(uint256 initial_supply)public{
        total_supply_=initial_supply;
        //Conectamos nuestro total supply a la cartera del creador
        //Esta cartera podria ser una cartera de distribucion por ejemplo
        dirrecion_Tokens[msg.sender]=total_supply_;
    }

    //Utilizamos safemath para operaciones seguras
    using SafeMath for uint256;

    function totalSupply()public override view returns(uint256){
        return total_supply_;
    }

    function balanceOf(address _dir) public override view returns(uint256){
        return dirrecion_Tokens[_dir];
    }

    function increaseTotalSupply(uint256 _tokens) public{
        total_supply_=total_supply_+_tokens;
        //Se anaden los tokens al que los has minado a su cartea ademas de al intial supply
        dirrecion_Tokens[msg.sender]=dirrecion_Tokens[msg.sender]+_tokens;
    }

    function allowence(address _owner,address _spender) public override view returns(uint256){
        //Nos devolvera cuantos tokens tiene un owner delegados en un spender
        return allowed[_owner][_spender];
    }

    function transfer(address _recipient,uint256 _quantity) public override returns(bool){
        //En este caso si utilizamos el tokenen otro contrato
        //El msg.sender sera el address del contrato y no de los clientes CUIDADO
        require(_quantity <= dirrecion_Tokens[msg.sender]);
        dirrecion_Tokens[msg.sender]=dirrecion_Tokens[msg.sender].sub(_quantity);
        
        dirrecion_Tokens[_recipient]=dirrecion_Tokens[_recipient].add(_quantity);
        emit Transfer(msg.sender,_recipient,_quantity);
        return true;
    }

    function transfer_disney(address _spender,address _recipient,uint256 _quantity) public override returns(bool){
        //En este caso si utilizamos el tokenen otro contrato
        //El msg.sender sera el address del contrato y no de los clientes CUIDADO
        require(_quantity <= dirrecion_Tokens[_spender]);
        dirrecion_Tokens[_spender]=dirrecion_Tokens[_spender].sub(_quantity);
        
        dirrecion_Tokens[_recipient]=dirrecion_Tokens[_recipient].add(_quantity);
        emit Transfer(_spender,_recipient,_quantity);
        return true;
    }

    function approve(address _spender, uint256 _quantity) public override  returns(bool){
        allowed[msg.sender][_spender]=_quantity;
        emit Approval(msg.sender,_spender,_quantity);
        return false;
    }

    function transferFrom(address _owner,address _buyer,uint256 _quantity)public override  returns(bool){
        require(_quantity <= dirrecion_Tokens[_owner]);
        //Esto indica si el numero de tokens es menor o igual a el numero de tokens que tenemos permitido gastar
        //de su cartera
        require(_quantity <= allowed[_owner][msg.sender]);
        //Quitanmos tokens al proveedor
        dirrecion_Tokens[_owner]= dirrecion_Tokens[_owner].sub(_quantity);
        //Quitamos tokens al intermediario
        allowed[_owner][msg.sender] =allowed[_owner][msg.sender].sub(_quantity);
        //Damos tokens al comprador
        dirrecion_Tokens[_buyer] = dirrecion_Tokens[_buyer].add(_quantity);
        emit Transfer(_owner,_buyer,_quantity);
        return true;
    }
}