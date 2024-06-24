%% Madwick Filter C code Implementation

% // System constants
% #define deltat 0.003f // sampling period in seconds (shown as 1 ms)
% #define gyroMeasError 3.14159265358979f * (5.0f / 180.0f) // gyroscope measurement error in rad/s (shown as 5 deg/s)
% #define beta sqrt(3.0f / 4.0f) * gyroMeasError // compute beta
% 
% // Global system variables
% float a_x, a_y, a_z; // accelerometer measurements
% float w_x, w_y, w_z; // gyroscope measurements in rad/s
% float q_w = 1.0f, q_x = 0.0f, q_y = 0.0f, q_z = 0.0f; (q_half_fix) // estimated orientation quaternion elements with initial conditions 
% float q_w_norm, q_x_norm, q_y_norm, q_z_norm;
% 
% void filterUpdate()
% {
%     // Local system variables
%     float norm; // vector norm
%     float SEqDot_omega_1, SEqDot_omega_2, SEqDot_omega_3, SEqDot_omega_4; // quaternion derivative from gyroscopes elements
%     float f_1, f_2, f_3; // objective function elements
%     float J_11or24, J_12or23, J_13or22, J_14or21, J_32, J_33; // objective function Jacobian elements
%     float SEqHatDot_1, SEqHatDot_2, SEqHatDot_3, SEqHatDot_4; // estimated direction of the gyroscope error
% 
%     // Auxiliary variables to avoid repeated calculations
%     float half_q_w = 0.5f * q_w;
%     float half_q_x = 0.5f * q_x;
%     float half_q_y = 0.5f * q_y;
%     float half_q_z = 0.5f * q_z;
% 
%     float two_q_w = 2.0f * q_w;
%     float two_q_x = 2.0f * q_x;
%     float two_q_y = 2.0f * q_y;
% 
%     // Normalise the accelerometer measurement
%     norm = sqrt(a_x * a_x + a_y * a_y + a_z * a_z);
%     a_x /= norm;
%     a_y /= norm;
%     a_z /= norm;
% 
%     // Compute the objective function and Jacobian
%     f_1 = two_q_x * q_z - two_q_w * q_y - a_x;
%     f_2 = two_q_w * q_x + two_q_y * q_z - a_y;
%     f_3 = 1.0f - two_q_x * q_x - two_q_y * q_y - a_z;
% 
%     J_11or24 = two_q_y; // J_11 negated in matrix multiplication
%     J_12or23 = 2.0f * q_z;
%     J_13or22 = two_q_w; // J_12 negated in matrix multiplication
%     J_14or21 = two_q_x;
% 
%     J_32 = 2.0f * J_14or21; // negated in matrix multiplication
%     J_33 = 2.0f * J_11or24; // negated in matrix multiplication
% 
%     // Compute the gradient (matrix multiplication)
%     SEqHatDot_1 = J_14or21 * f_2 - J_11or24 * f_1;
%     SEqHatDot_2 = J_12or23 * f_1 + J_13or22 * f_2 - J_32 * f_3;
%     SEqHatDot_3 = J_12or23 * f_2 - J_33 * f_3 - J_13or22 * f_1;
%     SEqHatDot_4 = J_14or21 * f_1 + J_11or24 * f_2;
% 
%     // Normalise the gradient
%     norm = sqrt(SEqHatDot_1 * SEqHatDot_1 + SEqHatDot_2 * SEqHatDot_2 + SEqHatDot_3 * SEqHatDot_3 + SEqHatDot_4 * SEqHatDot_4);
%     SEqHatDot_1 /= norm;
%     SEqHatDot_2 /= norm;
%     SEqHatDot_3 /= norm;
%     SEqHatDot_4 /= norm;
% 
%     // Compute the quaternion derivative measured by gyroscopes
%     SEqDot_omega_1 = -half_q_x * w_x - half_q_y * w_y - half_q_z * w_z;
%     SEqDot_omega_2 = half_q_w * w_x + half_q_y * w_z - half_q_z * w_y;
%     SEqDot_omega_3 = half_q_w * w_y - half_q_x * w_z + half_q_z * w_x;
%     SEqDot_omega_4 = half_q_w * w_z + half_q_x * w_y - half_q_y * w_x;
% 
%     // Compute then integrate the estimated quaternion derivative
%     q_w += (SEqDot_omega_1 - (beta * SEqHatDot_1)) * deltat;
%     q_x += (SEqDot_omega_2 - (beta * SEqHatDot_2)) * deltat;
%     q_y += (SEqDot_omega_3 - (beta * SEqHatDot_3)) * deltat;
%     q_z += (SEqDot_omega_4 - (beta * SEqHatDot_4)) * deltat;
% 
%     // Normalise quaternion
%     norm = sqrt(q_w * q_w + q_x * q_x + q_y * q_y + q_z * q_z);
%     q_w_norm = q_w / norm;
%     q_x_norm = q_x / norm;
%     q_y_norm = q_y / norm;
%     q_z_norm = q_z / norm;
% }

%% Parameters
% Input data properties 
INPUT_DATA_FILE_PATH = "processing\Data\mpu6050_data\MPU6050_ESP32_10000_points.csv";
data_in = readtable(INPUT_DATA_FILE_PATH);
% data_in = data_in(1:50, :);

REF_DATA_PATH = "processing\Data\filtered_data\filtered_output_23-06-24_16-47-37.csv";
data_out_ref = readtable(REF_DATA_PATH);
% data_out_ref = data_out_ref(1:50, :);

ACC_INPUT_RANGE = 2 * 9.81;
GYRO_INPUT_RANGE = 500 * pi/180;

global ACC_INT_WIDTH
global ACC_FRACT_WIDTH
global ACC_WIDTH
ACC_INT_WIDTH = 5;
ACC_FRACT_WIDTH = 6;
ACC_WIDTH = ACC_INT_WIDTH + ACC_FRACT_WIDTH;

global GYRO_INT_WIDTH
global GYRO_FRACT_WIDTH
global GYRO_WIDTH
GYRO_INT_WIDTH = 4;
GYRO_FRACT_WIDTH = 6;
GYRO_WIDTH = GYRO_INT_WIDTH + GYRO_FRACT_WIDTH;

global ACC_MAG_SQR_INT_WIDTH
global ACC_MAG_SQR_FRACT_WIDTH
global ACC_MAG_SQR_WIDTH
ACC_MAG_SQR_INT_WIDTH = 12;
ACC_MAG_SQR_FRACT_WIDTH = 4;
ACC_MAG_SQR_WIDTH = ACC_MAG_SQR_INT_WIDTH + ACC_MAG_SQR_FRACT_WIDTH;

global Q_HAT_DOT_MAG_SQR_INT_WIDTH
global Q_HAT_DOT_MAG_SQR_FRACT_WIDTH
global Q_HAT_DOT_MAG_SQR_WIDTH
Q_HAT_DOT_MAG_SQR_INT_WIDTH = 12;
Q_HAT_DOT_MAG_SQR_FRACT_WIDTH = 4;
Q_HAT_DOT_MAG_SQR_WIDTH = Q_HAT_DOT_MAG_SQR_INT_WIDTH + Q_HAT_DOT_MAG_SQR_FRACT_WIDTH;

global Q_MAG_SQR_INT_WIDTH
global Q_MAG_SQR_FRACT_WIDTH
global Q_MAG_SQR_WIDTH
Q_MAG_SQR_INT_WIDTH = 12;
Q_MAG_SQR_FRACT_WIDTH = 4;
Q_MAG_SQR_WIDTH = Q_MAG_SQR_INT_WIDTH + Q_MAG_SQR_FRACT_WIDTH;

global Q_INT_WIDTH
global Q_FRACT_WIDTH
global Q_WIDTH
Q_INT_WIDTH = 2;
Q_FRACT_WIDTH = 14;
Q_WIDTH = Q_INT_WIDTH + Q_FRACT_WIDTH;

% Input Data Analysis
% Acceleration normal distribution
x_pd = -ACC_INPUT_RANGE:1e-3:ACC_INPUT_RANGE;
y_ax = pdf(fitdist(data_in.ax, "Normal"), x_pd);
y_ay = pdf(fitdist(data_in.ay, "Normal"), x_pd);
y_az = pdf(fitdist(data_in.az, "Normal"), x_pd);
figure();
hold on
plot(x_pd, y_ax, DisplayName="x")
plot(x_pd, y_ay, DisplayName="y")
plot(x_pd, y_az, DisplayName="z")
legend()
xlabel("Acceleration [m/s]")
ylabel("Probability")
title("Normal Probability Distribution of Measured Acceleration")
grid on

% Gyro rate normal distribution
x_pd = -GYRO_INPUT_RANGE:1e-3:GYRO_INPUT_RANGE;
y_ax = pdf(fitdist(data_in.wx, "Normal"), x_pd);
y_ay = pdf(fitdist(data_in.wy, "Normal"), x_pd);
y_az = pdf(fitdist(data_in.wz, "Normal"), x_pd);
figure();
hold on
plot(x_pd, y_ax, DisplayName="x")
plot(x_pd, y_ay, DisplayName="y")
plot(x_pd, y_az, DisplayName="z")
legend()
xlabel("Gyro rate [rad/s]")
ylabel("Probability")
title("Normal Probability Distribution of Measured Gyro Rates")
grid on

%% Constants
global delta_t_fix
delta_t = 0.003;
delta_t_fix = fi(delta_t);

gyro_meas_error_deg = 5;
gyro_meas_error_rad = pi * gyro_meas_error_deg / 180;
gyro_meas_error_fix = fi(gyro_meas_error_rad);

global beta_fix
beta = sqrt(3/4) * gyro_meas_error_rad;
beta_fix = fi(beta);

%% Inputs 
acc = [0, 0, 0];
acc_fix = [fi(acc(1), 1, ACC_WIDTH, ACC_FRACT_WIDTH), fi(acc(2), 1, ACC_WIDTH, ACC_FRACT_WIDTH), fi(acc(3), 1, ACC_WIDTH, ACC_FRACT_WIDTH)];

gyro = [0, 0, 0];
gyro_fix = [fi(gyro(1), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH), fi(gyro(2), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH), fi(gyro(3), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH)];

%% Main
data_out = zeros(height(data_in), 4);
q_fix = [fi(1, 1, Q_WIDTH, Q_FRACT_WIDTH), fi(0, 1, Q_WIDTH, Q_FRACT_WIDTH), fi(0, 1, Q_WIDTH, Q_FRACT_WIDTH), fi(0, 1, Q_WIDTH, Q_FRACT_WIDTH)];

for i = 1:height(data_in)

    acc_fix = [fi(data_in.ax(i), 1, ACC_WIDTH, ACC_FRACT_WIDTH), fi(data_in.ay(i), 1, ACC_WIDTH, ACC_FRACT_WIDTH), fi(data_in.az(i), 1, ACC_WIDTH, ACC_FRACT_WIDTH)];
    gyro_fix = [fi(data_in.wx(i), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH), fi(data_in.wy(i), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH), fi(data_in.wz(i), 1, GYRO_WIDTH, GYRO_FRACT_WIDTH)];

    q_fix = madgwickFixedPoint(q_fix, acc_fix, gyro_fix);
    q_w_fix = q_fix(1);
    q_x_fix = q_fix(2);
    q_y_fix = q_fix(3);
    q_z_fix = q_fix(4);

    q_w = single(int(q_w_fix)) * 2^-q_w_fix.FractionLength;
    q_x = single(int(q_x_fix)) * 2^-q_x_fix.FractionLength;
    q_y = single(int(q_y_fix)) * 2^-q_y_fix.FractionLength;
    q_z = single(int(q_z_fix)) * 2^-q_z_fix.FractionLength;

    data_out(i, :) = [q_w, q_x, q_y, q_z];
end

create_header_file();

%% Evaluate Error
q_w_mse = immse(table2array(data_out_ref(:, 7)),  data_out(:, 1));
q_x_mse = immse(table2array(data_out_ref(:, 8)),  data_out(:, 2));
q_y_mse = immse(table2array(data_out_ref(:, 9)),  data_out(:, 3));
q_z_mse = immse(table2array(data_out_ref(:, 10)),  data_out(:, 4));

q_mse = [q_w_mse, q_x_mse, q_y_mse, q_z_mse];

%% Fixed-Point Madgwick Computation Function
function [q_norm_fix] = madgwickFixedPoint(q_prev_fix, acc_fix, gyro_fix)

    % Global imports
    global ACC_FRACT_WIDTH
    global ACC_WIDTH
    global GYRO_FRACT_WIDTH
    global GYRO_WIDTH
    global ACC_MAG_SQR_FRACT_WIDTH
    global ACC_MAG_SQR_WIDTH
    global Q_HAT_DOT_MAG_SQR_FRACT_WIDTH
    global Q_HAT_DOT_MAG_SQR_WIDTH
    global Q_MAG_SQR_FRACT_WIDTH
    global Q_MAG_SQR_WIDTH
    global Q_FRACT_WIDTH
    global Q_WIDTH
    global delta_t_fix
    global beta_fix

    % Global definitions


    % Expand inputs
    q_w_prev_fix = q_prev_fix(1);
    q_x_prev_fix = q_prev_fix(2);
    q_y_prev_fix = q_prev_fix(3);
    q_z_prev_fix = q_prev_fix(4);

    acc_x_fix = acc_fix(1);
    acc_y_fix = acc_fix(2);
    acc_z_fix = acc_fix(3);

    gyro_x_fix = gyro_fix(1);
    gyro_y_fix = gyro_fix(2);
    gyro_z_fix = gyro_fix(3);

    % Auxiliary variables to avoid repeated calculations
    q_w_half_fix = bitsra(q_w_prev_fix, 1);  % Arithmetic bit shift right by 1 to half value 
    q_x_half_fix = bitsra(q_x_prev_fix, 1);
    q_y_half_fix = bitsra(q_y_prev_fix, 1);
    q_z_half_fix = bitsra(q_z_prev_fix, 1);

    q_w_two_fix = q_w_prev_fix + q_w_prev_fix;  % Arithmetic bit shift left by 1 to double value (Arithmetic bit shift left in Verilog)
    q_x_two_fix = q_x_prev_fix + q_x_prev_fix;
    q_y_two_fix = q_y_prev_fix + q_y_prev_fix;

    % Normalise acceleration vector
    acc_mag_sqr_fix = acc_x_fix * acc_x_fix + acc_y_fix * acc_y_fix + acc_z_fix * acc_z_fix;   % compute magnitude squared
    acc_mag_sqr_fix_trun = fi(double(acc_mag_sqr_fix), 0, ACC_MAG_SQR_WIDTH, ACC_MAG_SQR_FRACT_WIDTH);  % Truncate to fastInvSqrtAccNorm word width
    acc_mag_inv_fix = fixFastInvSqrt(acc_mag_sqr_fix_trun);  % Compute inverse of magnitude
    acc_x_norm_fix = acc_x_fix * acc_mag_inv_fix;   % Apply normalisation
    acc_y_norm_fix = acc_y_fix * acc_mag_inv_fix;
    acc_z_norm_fix = acc_z_fix * acc_mag_inv_fix;

    % Truncate acceleration vector
    acc_x_norm = double(acc_x_norm_fix);
    acc_y_norm = double(acc_y_norm_fix);
    acc_z_norm = double(acc_z_norm_fix);
    acc_x_norm_fix_trunc = fi(acc_x_norm, 1, ACC_WIDTH, ACC_FRACT_WIDTH);
    acc_y_norm_fix_trunc = fi(acc_y_norm, 1, ACC_WIDTH, ACC_FRACT_WIDTH);
    acc_z_norm_fix_trunc = fi(acc_z_norm, 1, ACC_WIDTH, ACC_FRACT_WIDTH);

    % Compute Objective Function
    f_1_fix = q_x_two_fix * q_z_prev_fix - q_w_two_fix * q_y_prev_fix - acc_x_norm_fix_trunc;  %  f_1 = two_q_x * q_z - two_q_w * q_y - a_x;
    f_2_fix = q_w_two_fix * q_x_prev_fix + q_y_two_fix * q_z_prev_fix - acc_y_norm_fix_trunc;  % f_2 = two_q_w * q_x + two_q_y * q_z - a_y;
    f_3_fix = 1 - q_x_two_fix * q_x_prev_fix - q_y_two_fix * q_y_prev_fix - acc_z_norm_fix_trunc;   %f_3 = 1.0f - two_q_x * q_x - two_q_y * q_y - a_z

    % Compute Jacobian
    j_11_24_fix = q_y_two_fix;  % J_11or24 = two_q_y
    j_12_23_fix = q_z_prev_fix + q_z_prev_fix;  % J_12or23 = 2.0f * q_z (Arithmetic bit shift left in Verilog)
    j_13_22_fix = q_w_two_fix;  % J_13or22 = two_q_w
    j_14_21_fix = q_x_two_fix;  % J_14or21 = two_q_x
    j_32_fix = j_14_21_fix + j_14_21_fix;    % J_32 = 2.0f * J_14or21; (Arithmetic bit shift left in Verilog)
    j_33_fix = j_11_24_fix + j_11_24_fix;    % J_33 = 2.0f * J_11or24; (Arithmetic bit shift left in Verilog)

    % Compute gyro error gradient
    q_hat_dot_w_fix = j_14_21_fix * f_2_fix - j_11_24_fix * f_1_fix;    % SEqHatDot_1 = J_14or21 * f_2 - J_11or24 * f_1;
    q_hat_dot_x_fix = j_12_23_fix * f_1_fix + j_13_22_fix * f_2_fix - j_32_fix * f_3_fix;   % SEqHatDot_2 = J_12or23 * f_1 + J_13or22 * f_2 - J_32 * f_3; 
    q_hat_dot_y_fix = j_12_23_fix * f_2_fix - j_33_fix * f_3_fix - j_13_22_fix * f_1_fix;   % SEqHatDot_3 = J_12or23 * f_2 - J_33 * f_3 - J_13or22 * f_1;
    q_hat_dot_z_fix = j_14_21_fix * f_1_fix + j_11_24_fix * f_2_fix; %  SEqHatDot_4 = J_14or21 * f_1 + J_11or24 * f_2;

    % Normalise gyro error gradient
    q_hat_dot_mag_sqr_fix = q_hat_dot_w_fix * q_hat_dot_w_fix + q_hat_dot_x_fix * q_hat_dot_x_fix + q_hat_dot_y_fix * q_hat_dot_y_fix + q_hat_dot_z_fix * q_hat_dot_z_fix;  % Compute mag sqr
    q_hat_mag_sqr_fix_trun = fi(double(q_hat_dot_mag_sqr_fix), 0, Q_HAT_DOT_MAG_SQR_WIDTH, Q_HAT_DOT_MAG_SQR_FRACT_WIDTH);
    q_hat_dot_mag_inv_fix = fixFastInvSqrt(q_hat_mag_sqr_fix_trun);
    q_hat_dot_norm_w_fix = q_hat_dot_w_fix * q_hat_dot_mag_inv_fix;
    q_hat_dot_norm_x_fix = q_hat_dot_x_fix * q_hat_dot_mag_inv_fix;
    q_hat_dot_norm_y_fix = q_hat_dot_y_fix * q_hat_dot_mag_inv_fix;
    q_hat_dot_norm_z_fix = q_hat_dot_z_fix * q_hat_dot_mag_inv_fix;

    % Compute gyro quaternion derivative
    q_dot_w_w_fix = -q_x_half_fix * gyro_x_fix - q_y_half_fix * gyro_y_fix - q_z_half_fix * gyro_z_fix;   % SEqDot_omega_1 = -half_q_x * w_x - half_q_y * w_y - half_q_z * w_z;
    q_dot_w_x_fix = q_w_half_fix * gyro_x_fix + q_y_half_fix * gyro_z_fix - q_z_half_fix * gyro_y_fix; % SEqDot_omega_2 = half_q_w * w_x + half_q_y * w_z - half_q_z * w_y;
    q_dot_w_y_fix = q_w_half_fix * gyro_y_fix - q_x_half_fix * gyro_z_fix + q_z_half_fix * gyro_x_fix; % SEqDot_omega_3 = half_q_w * w_y - half_q_x * w_z + half_q_z * w_x;
    q_dot_w_z_fix = q_w_half_fix * gyro_z_fix + q_x_half_fix * gyro_y_fix - q_y_half_fix * gyro_x_fix; % SEqDot_omega_4 = half_q_w * w_z + half_q_x * w_y - half_q_y * w_x;

    % Combine acceleration and gyro rate quaternion derivative estimates and integrate
    q_w_fix = q_w_prev_fix + (q_dot_w_w_fix - (beta_fix * q_hat_dot_norm_w_fix)) * delta_t_fix; % q_w += (SEqDot_omega_1 - (beta * SEqHatDot_1)) * deltat;
    q_x_fix = q_x_prev_fix + (q_dot_w_x_fix - (beta_fix * q_hat_dot_norm_x_fix)) * delta_t_fix;
    q_y_fix = q_y_prev_fix + (q_dot_w_y_fix - (beta_fix * q_hat_dot_norm_y_fix)) * delta_t_fix;
    q_z_fix = q_z_prev_fix + (q_dot_w_z_fix - (beta_fix * q_hat_dot_norm_z_fix)) * delta_t_fix;

    % Normalise quaternion estimate
    q_mag_sqr_fix = q_w_fix * q_w_fix + q_x_fix * q_x_fix + q_y_fix * q_y_fix + q_z_fix * q_z_fix;
    q_mag_sqr_fix_trun = fi(double(q_mag_sqr_fix), 0, Q_MAG_SQR_WIDTH, Q_MAG_SQR_FRACT_WIDTH);
    q_mag_inv_fix = fixFastInvSqrt(q_mag_sqr_fix_trun);
    q_w_norm_fix = q_w_fix * q_mag_inv_fix;
    q_x_norm_fix = q_x_fix * q_mag_inv_fix;
    q_y_norm_fix = q_y_fix * q_mag_inv_fix;
    q_z_norm_fix = q_z_fix * q_mag_inv_fix;

    % Truncate quaternion estimate
    q_w_norm_fix_trun = fi(double(q_w_norm_fix), 1, Q_WIDTH, Q_FRACT_WIDTH);
    q_x_norm_fix_trun = fi(double(q_x_norm_fix), 1, Q_WIDTH, Q_FRACT_WIDTH);
    q_y_norm_fix_trun = fi(double(q_y_norm_fix), 1, Q_WIDTH, Q_FRACT_WIDTH);
    q_z_norm_fix_trun = fi(double(q_z_norm_fix), 1, Q_WIDTH, Q_FRACT_WIDTH);

    % Return as an array of fixed-point values
    q_norm_fix = [q_w_norm_fix_trun, q_x_norm_fix_trun, q_y_norm_fix_trun, q_z_norm_fix_trun];

end

%% Fixed-Point Fast Inverse Square Root Function
function [fix] = fixFastInvSqrt(x)

    word_length = x.WordLength;
    fract_length = x.FractionLength;

    % Compute x_half
    half = fi(0.5, 0, 1, 1);
    x_half = x * half;

    % Convert to float
    x_float = single(int(x)) * 2^-x.FractionLength;
    x_int = typecast(single(x_float), 'uint32'); % Cast as integer

    % Bit shift right by 1
    x_int = bitsrl(x_int, 1);

    % Integer subtract from magic hex value
    x = uint32(hex2dec("5f3759df")) - x_int;

    % Convert back to fixed point
    x = typecast(uint32(x), 'single'); % Cast as float
    x = fi(x, 0, word_length, fract_length);

    % Newton-Raphson method
    A = x_half * x * x;
    one_and_half = fi(1.5, 0, A.WordLength, A.FractionLength);
    fix = x * (one_and_half - A);

    % Normalise word length
    fix = fi(fix, 0, word_length, fract_length);

end

%% Verilog Header File Generation Function
function [] = create_header_file()

    global ACC_INT_WIDTH
    global ACC_FRACT_WIDTH
    global ACC_MAG_SQR_FRACT_WIDTH
    global ACC_MAG_SQR_INT_WIDTH
    global Q_HAT_DOT_MAG_SQR_FRACT_WIDTH
    global Q_HAT_DOT_MAG_SQR_INT_WIDTH
    global Q_MAG_SQR_FRACT_WIDTH
    global Q_MAG_SQR_INT_WIDTH
    global Q_FRACT_WIDTH
    global Q_INT_WIDTH

    header_file = fopen("madgwick.vh", 'w');
    fprintf(header_file, sprintf('`Define ACC_INT_WIDTH %d\n', ACC_INT_WIDTH));
    fprintf(header_file, sprintf('`Define ACC_FRACT_WIDTH %d\n', ACC_FRACT_WIDTH));
    fprintf(header_file, sprintf('`Define ACC_MAG_SQR_INT_WIDTH %d\n', ACC_MAG_SQR_INT_WIDTH));
    fprintf(header_file, sprintf('`Define ACC_MAG_SQR_FRACT_WIDTH %d\n', ACC_MAG_SQR_FRACT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_HAT_DOT_MAG_SQR_INT_WIDTH %d\n', Q_HAT_DOT_MAG_SQR_INT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_HAT_DOT_MAG_SQR_FRACT_WIDTH %d\n', Q_HAT_DOT_MAG_SQR_FRACT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_MAG_SQR_INT_WIDTH %d\n', Q_MAG_SQR_INT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_MAG_SQR_FRACT_WIDTH %d\n', Q_MAG_SQR_FRACT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_INT_WIDTH %d\n', Q_INT_WIDTH));
    fprintf(header_file, sprintf('`Define Q_FRACT_WIDTH %d\n', Q_FRACT_WIDTH));

    fclose(header_file);

end

