#include <stdio.h>
#include <math.h>

// System constants
#define deltat 0.003f // sampling period in seconds (shown as 1 ms)
#define gyroMeasError 3.14159265358979f * (5.0f / 180.0f) // gyroscope measurement error in rad/s (shown as 5 deg/s)
#define beta sqrt(3.0f / 4.0f) * gyroMeasError // compute beta

// Global system variables
float a_x, a_y, a_z; // accelerometer measurements
float w_x, w_y, w_z; // gyroscope measurements in rad/s
float q_w = 1.0f, q_x = 0.0f, q_y = 0.0f, q_z = 0.0f; // estimated orientation quaternion elements with initial conditions
float q_w_norm, q_x_norm, q_y_norm, q_z_norm;

void filterUpdate()
{
    // Local system variables
    float norm; // vector norm
    float SEqDot_omega_1, SEqDot_omega_2, SEqDot_omega_3, SEqDot_omega_4; // quaternion derivative from gyroscopes elements
    float f_1, f_2, f_3; // objective function elements
    float J_11or24, J_12or23, J_13or22, J_14or21, J_32, J_33; // objective function Jacobian elements
    float SEqHatDot_1, SEqHatDot_2, SEqHatDot_3, SEqHatDot_4; // estimated direction of the gyroscope error

    // Auxiliary variables to avoid repeated calculations
    float half_q_w = 0.5f * q_w;
    float half_q_x = 0.5f * q_x;
    float half_q_y = 0.5f * q_y;
    float half_q_z = 0.5f * q_z;

    float two_q_w = 2.0f * q_w;
    float two_q_x = 2.0f * q_x;
    float two_q_y = 2.0f * q_y;

    // Normalise the accelerometer measurement
    norm = sqrt(a_x * a_x + a_y * a_y + a_z * a_z);
    a_x /= norm;
    a_y /= norm;
    a_z /= norm;

    // Compute the objective function and Jacobian
    f_1 = two_q_x * q_z - two_q_w * q_y - a_x;
    f_2 = two_q_w * q_x + two_q_y * q_z - a_y;
    f_3 = 1.0f - two_q_x * q_x - two_q_y * q_y - a_z;

    J_11or24 = two_q_y; // J_11 negated in matrix multiplication
    J_12or23 = 2.0f * q_z;
    J_13or22 = two_q_w; // J_12 negated in matrix multiplication
    J_14or21 = two_q_x;

    J_32 = 2.0f * J_14or21; // negated in matrix multiplication
    J_33 = 2.0f * J_11or24; // negated in matrix multiplication

    // Compute the gradient (matrix multiplication)
    SEqHatDot_1 = J_14or21 * f_2 - J_11or24 * f_1;
    SEqHatDot_2 = J_12or23 * f_1 + J_13or22 * f_2 - J_32 * f_3;
    SEqHatDot_3 = J_12or23 * f_2 - J_33 * f_3 - J_13or22 * f_1;
    SEqHatDot_4 = J_14or21 * f_1 + J_11or24 * f_2;

    // Normalise the gradient
    norm = sqrt(SEqHatDot_1 * SEqHatDot_1 + SEqHatDot_2 * SEqHatDot_2 + SEqHatDot_3 * SEqHatDot_3 + SEqHatDot_4 * SEqHatDot_4);
    SEqHatDot_1 /= norm;
    SEqHatDot_2 /= norm;
    SEqHatDot_3 /= norm;
    SEqHatDot_4 /= norm;

    // Compute the quaternion derivative measured by gyroscopes
    SEqDot_omega_1 = -half_q_x * w_x - half_q_y * w_y - half_q_z * w_z;
    SEqDot_omega_2 = half_q_w * w_x + half_q_y * w_z - half_q_z * w_y;
    SEqDot_omega_3 = half_q_w * w_y - half_q_x * w_z + half_q_z * w_x;
    SEqDot_omega_4 = half_q_w * w_z + half_q_x * w_y - half_q_y * w_x;

    // Compute then integrate the estimated quaternion derivative
    q_w += (SEqDot_omega_1 - (beta * SEqHatDot_1)) * deltat;
    q_x += (SEqDot_omega_2 - (beta * SEqHatDot_2)) * deltat;
    q_y += (SEqDot_omega_3 - (beta * SEqHatDot_3)) * deltat;
    q_z += (SEqDot_omega_4 - (beta * SEqHatDot_4)) * deltat;

    // Normalise quaternion
    norm = sqrt(q_w * q_w + q_x * q_x + q_y * q_y + q_z * q_z);
    q_w_norm = q_w / norm;
    q_x_norm = q_x / norm;
    q_y_norm = q_y / norm;
    q_z_norm = q_z / norm;
}

int main()
{
    scanf("%f %f %f %f %f %f %f %f %f %f", &a_x, &a_y, &a_z, &w_x, &w_y, &w_z, &q_w, &q_x, &q_y, &q_z);
    filterUpdate();
    printf("%.5f\t%.5f\t%.5f\t%.5f", q_w, q_x, q_y, q_z);
    printf("\n");

    return 0;
}

// int main()
// {
//     a_x = -1.1250;
//     a_y = 5.1562;
//     a_z = 3.0625;

//     w_x = -0.8750; 
//     w_y = 0.3594;  
//     w_z = -0.6719;

//     filterUpdate();

//     return 0;
// }