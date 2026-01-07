// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo({
            text: _text,
            completed: false
        }));
    }

    function updateText(uint _index, string calldata _text) external {
        todos[_index].text = _text;
        // This takes more gas because i access the array every time
        // todos[_index].text = _text;
        // todos[_index].text = _text;
        // todos[_index].text = _text;

        // Todo storage todo = todos[_index];
        // // Here i access the array only once and then update it 4 times
        // todo.text = _text;
        // todo.text = _text;
        // todo.text = _text;
    }

    function get(uint _i) external view returns (string memory, bool) {
        Todo memory todo = todos[_i];
        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
    
}