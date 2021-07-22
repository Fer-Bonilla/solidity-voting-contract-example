// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TestSender{
    
  event Response(bool success, bytes data);
  
  function send(address payable _to) public payable {
        (bool success, bytes memory data) =
            _to.call{value: msg.value, gas: 5000}(
                abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
            );

        emit Response(success, data);
  }
  
  function getBalance() public view returns(uint256){
      return address(this).balance;
  }

  fallback() external payable {
      
  }

  receive() external payable {

  }
    
}

