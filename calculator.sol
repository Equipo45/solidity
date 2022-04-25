pragma solidity >= 0.8.0 < 0.9.0;


contract calculadora{

    function sumar(uint a, uint b) public pure returns(uint){
        return a+b;
    }

    function restar(uint a, uint b) public pure returns(uint){
        return a-b;
    }

    function multiplicar(uint a, uint b) public pure returns(uint){
        return a*b;
    }
}