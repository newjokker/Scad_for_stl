


// 3. 缩小的正方形拉伸
linear_extrude(height = 3, center = true) {
    offset(r = -1) {
        square(10);
    }
}