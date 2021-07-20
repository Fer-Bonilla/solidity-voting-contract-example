# Solidity voting contract example

Example of basic implementation for a votind contract developed in Solidiy and running over the Ethereum blockchain

The voting contract has this functionalities:

- The voting has only 6 fixed options: “0” or “1” or “2” or “3” or “4” or “5”. Each nonzero option corresponds to 1 candidate (i.e., in total, there are 5 candidates). The zero
option (“0”) denotes a blank vote and, thus, it cannot be associated with any candidate.

- The voting process is kept open (i.e., voting is permitted) during a certain time frame which is specified by the creator of the contract.

- The votes can come only from addresses that are marked as “authorized”. The creator of the contract must mark all permitted addresses as “authorized” before the voting can
begin (write a function that would help the creator to mark an address as “authorized”).

- To prevent cheating, each verified address can vote only once - after voting, the address is marked as “unauthorized” and thus can't vote again.

- Write a function that returns the winner. In order to have a winner, two conditions should be satisfied as follows: (i) The winner should have at least the 60% of votes, and
(ii) When (i) holds, the percentage of blank votes should be less or equal to 15%. Otherwise, there is no winner.

- The contract should not accept any funds sent to it. Any funds sent to the contract (e.g., by accident) should be returned to the sender.
