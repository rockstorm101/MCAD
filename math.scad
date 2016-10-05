// MIT license

include <constants.scad>

function deg(angle) = 360*angle/TAU;

/*
   Function: round_down
             round_up
   Rounds a number up or down to a specified number of decimal places.

   Parameters:
      float x - The number to be rounded.
      int   p - The number of decimals desired. Default is 0. Negative numbers
                will round x to the tens, hundreds,...

   Example:
      round_down(1428.826,  2) = 1428.82
      round_up  (1428.826, -2) = 1500.00

   About: Author
      2016 Rock Storm
*/
function round_down(x, p) = x - x%pow(10,-p);
function round_up(x, p) = x - x%pow(10,-p) + pow(10,-p);

