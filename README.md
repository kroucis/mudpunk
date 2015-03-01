MUDPunk
========
A Ruby multi-user dungeon.
--------------------------
Created by Kyle Roucis ([www.kyleroucis.com](http://www.kyleroucis.com/)). Copyright (c) 2012. All rights reserved.

The MUDPunk framework and its constituent files (MUDPunk) is provided free of
charge. You are hereby granted the right to copy, distribute, and modify this
software provided any substantial copy, distribution, or modification reproduces
the above copyright, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution, and 
provides appropriate attribution to the software's author(s).

This documentation is provided "as is" and any express or implied warranties, 
including, but not limited to, the implied warranties of merchantability and 
fitness for a particular purpose are disclaimed. In no event shall the authors 
be liable for any direct, indirect, incidental, special, exemplary, or 
consequential damages (including, but not limited to, procurement of substitute 
goods or services; loss of use, data, or profits; or business interruption) 
however caused and on any theory of liability, whether in contract, strict 
liability, or tort (including negligence or otherwise) arising in any way out 
of the use of this documentation, even if advised of the possibility of such 
damage.

Runtime
-------
You MUST use Ruby 1.9.2 or higher with MUD Punk as it uses the new hash syntax 
and will not build below 1.9. It is recommended (but not required) to use
Rubinius 2.0.0 (current head). The Rakefile will invoke

	rbx -X19 mud/mudpunk.rb

which means rake should be invoked from the project root.

*UPDATE*
Rubinius has been broken for some time now. However, simply invoking

    ruby mud/mudpunk.rb

will be sufficient to run MUD Punk provided you have the eventmachine gem installed

Dependencies (gems)
-------------------
* eventmachine 1.0.0+
* bundler 3.1.0+ (planned)
* rake 0.9.2.2+

Running
-------
By default, MUDPunk starts up on localhost on port 8888. From the root of the
project, with Rubinius-head, rake, eventmachine, and rvm in place, simply invoke
`rake`. This will build and launch the server as a blocking process.

Open a second terminal and

`telnet localhost 8888`

You will be prompted to enter a name and will be dumped into the starting area.
The `cmdlist` will list all handled commands (currently many debug and non-user-
friendly commands exist). You may target items in containers using the syntax

    - Room
    ^ Inventory
    * Equipment
    = World

You may specify which item in a list to select using `#<number>`.
For example, if you were carrying 3 cats, typing `inv` would show

    cat
    cat
    cat

To drop cat number 1 (starting from 0, of course!) one would enter

    drop ^cat#1

However, drop implies ^ (inventory), while take implies - (room). Most commands
list which container they start searching in and list which containers they
affect. Drop's signature is `[^] => [-]` (inventory to room). Invoking `drop 
cat` will find the first instance of cat in your inventory.

Contact
-------
If you encounter any issues, bugs, or suggestions do not hesitate to contact
MUDPunk's maintainer (currently its creator: 
[Kyle Roucis](mailto:kyle@kyleroucis.com).
