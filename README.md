MUDPunk
========
A Ruby multi-user dungeon.
--------------------------
Created by Kyle Roucis. Copyright (c) 2012. All rights reserved.

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
----------------------------------------------------------------

Runtime
-------
You MUST use Ruby 1.9.2 or higher with MUD Punk as it uses the new hash syntax 
and will not build below 1.9. It is recommended (but not required) to use
Rubinius 2.0.0 (current head). The Rakefile will invoke
	rbx -X19 mud/mudpunk.rb
which means rake should be invoked from the project root.

Dependencies (gems)
-------------------
* eventmachine 1.0.0+
* bundler 3.1.0+ (planned)
* rake 0.9.2.2+

Contact
-------
If you encounter any issues, bugs, or suggestions do not hesitate to contact
MUDPunk's maintainer (currently its creator: Kyle Roucis) at
    kyle@kyleroucis.com
