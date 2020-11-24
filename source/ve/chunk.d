module ve.chunk;

import ve.block;

class Chunk(T)
{
    uint x;
    uint y;
    uint z;

    Block!(T)[][][] blocks;

    this(uint width, uint height, uint depth)
    {
        this.x = width;
        this.y = height;
        this.z = depth;
        this.blocks = new Block!(T)[][][](width, height, depth);
    }

    void setBlock(uint x, uint y, uint z, Block!T block)
    {
        this.blocks[x][y][z] = block;
    }

    Block!T getBlock(uint x, uint y, uint z)
    {
        return this.blocks[x][y][z];
    }
}

unittest
{
    auto c = new Chunk!int(256, 256, 256);
    assert(c.x == 256);
    assert(c.y == 256);
    assert(c.z == 256);

    auto b = c.getBlock(0, 0, 0);
    assert(b.type == 0);
    Block!int one = 1;
    c.setBlock(0, 0, 0, one);
    b = c.getBlock(0, 0, 0);
    assert(b.type == 1);

    import core.exception;
    import std.exception;

    assertThrown!RangeError(c.setBlock(999, 999, 999, one));
    assertThrown!RangeError(c.getBlock(999, 999, 999));
}
