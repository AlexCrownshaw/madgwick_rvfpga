import os
import sys
import time

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation

from typing import Union


class Quaternion:

    @staticmethod
    def to_array(vec: Union[list, np.array, pd.DataFrame]) -> np.array:
        """

        :param vec:
        :return:
        """

        if type(vec) is pd.DataFrame:
            vec = vec.to_numpy()
        elif type(vec) is list:
            vec = np.array(vec)

        return vec

    @classmethod
    def from_euler(cls, e: Union[list, np.array]) -> np.array:
        """
        Returns a quaternion matrix from a right hand Tait-Bryan Euler angle matrix
        :param e: right hand Tait-Bryan Euler angle matrix
        return: quaternion matrix
        """

        e = cls.to_array(vec=e)

        e = np.radians(e / 2)
        cos_psi, cos_theta, cos_phi = np.cos(e[0]), np.cos(e[1]), np.cos(e[2])
        sin_psi, sin_theta, sin_phi = np.sin(e[0]), np.sin(e[1]), np.sin(e[2])

        q = np.zeros(4)
        q[0] = (cos_phi * cos_theta * cos_psi) + (sin_phi * sin_theta * sin_psi)
        q[1] = (sin_phi * cos_theta * cos_psi) - (cos_phi * sin_theta * sin_psi)
        q[2] = (cos_phi * sin_theta * cos_psi) + (sin_phi * cos_theta * sin_psi)
        q[3] = (cos_phi * cos_theta * sin_psi) - (sin_phi * sin_theta * cos_psi)

        return q

    @classmethod
    def to_euler(cls, q: Union[list, np.array]) -> np.array:
        """
        Returns a right hand Tait-Bryan Euler angle matrix from a quaternion matrix
        :param q: quaternion matrix
        return: euler angle vector
        """

        q = cls.to_array(vec=q)

        e = np.zeros(3)
        e[0] = np.arctan2(2 * ((q[0] * q[3]) + (q[1] * q[2])), (q[0] ** 2 + q[1] ** 2 - q[2] ** 2 - q[3] ** 2))
        e[1] = np.arcsin(2 * ((q[0] * q[2]) - (q[1] * q[3])))
        e[2] = np.arctan2(2 * ((q[0] * q[1]) + (q[2] * q[3])), (q[0] ** 2 - q[1] ** 2 - q[2] ** 2 + q[3] ** 2))

        return np.degrees(e)

    @classmethod
    def dot_product(cls, q1: Union[list, np.array], q2: Union[list, np.array], norm: bool = False) -> np.array:
        """
        Quaternion dot product multiplication (Non-commutable)
        :param q1:
        :param q2:
        :param norm:
        :return: q2 * q1
        """

        q1 = cls.to_array(vec=q1)
        q2 = cls.to_array(vec=q2)

        q_r = np.array([q1[0] * q2[0] - q1[1] * q2[1] - q1[2] * q2[2] - q1[3] * q2[3],
                        q1[0] * q2[1] + q1[1] * q2[0] + q1[2] * q2[3] - q1[3] * q2[2],
                        q1[0] * q2[2] - q1[1] * q2[3] + q1[2] * q2[0] + q1[3] * q2[1],
                        q1[0] * q2[3] + q1[1] * q2[2] - q1[2] * q2[1] + q1[3] * q2[0]])

        if norm:
            q_r = cls.normalise(q=q_r)

        return q_r

    @classmethod
    def inverse(cls, q: Union[list, np.array]) -> np.array:
        """

        :param q:
        :return:
        """

        return np.array([q[0], -q[1], -q[2], -q[3]])

    @classmethod
    def normalise(cls, q: Union[list, np.array]) -> np.array:
        """

        :param q:
        :return:
        """

        mag = np.sqrt(q[0] ** 2 + q[1] ** 2 + q[2] ** 2 + q[3] ** 2)
        x = np.array(q / mag)
        return np.array(q / mag)

    @classmethod
    def rotate_point(cls, p: Union[list, np.array], q: Union[list, np.array], active: bool = True) -> np.array:
        """

        :param p:
        :param q:
        :param active:
        :return:
        """

        p = np.array([0, p[0], p[1], p[2]])

        q = cls.to_array(vec=q)
        q_inv = cls.inverse(q=q)

        if active:
            p_prime = cls.dot_product(q1=cls.dot_product(q1=q_inv, q2=p), q2=q)
        else:
            p_prime = cls.dot_product(q1=cls.dot_product(q1=q, q2=p), q2=q_inv)

        return p_prime[1:]

    @classmethod
    def plot_quaternion(cls, q: Union[list, np.array], show: bool = True) -> plt.Figure:
        """

        :param q:
        :param show:
        :return:
        """

        q = cls.to_array(vec=q)

        p_x = cls.rotate_point(p=[1, 0, 0], q=q, active=True)
        p_y = cls.rotate_point(p=[0, 1, 0], q=q, active=True)
        p_z = cls.rotate_point(p=[0, 0, -1], q=q, active=True)

        fig = plt.figure()
        ax = fig.add_subplot(111, projection="3d")

        ax.quiver(0, 0, 0, p_x[0], p_x[1], p_x[2], length=1, color="r", label="x")
        ax.quiver(0, 0, 0, p_y[0], p_y[1], p_y[2], length=1, color="g", label="y")
        ax.quiver(0, 0, 0, p_z[0], p_z[1], p_z[2], length=1, color="b", label="z")

        ax.plot([0, 1], [0, 0], [0, 0], color="r", linestyle="--")
        ax.plot([0, 0], [0, 1], [0, 0], color="g", linestyle="--")
        ax.plot([0, 0], [0, 0], [0, -1], color="b", linestyle="--")

        ax.set(xlim=(-1, 1))
        ax.set(ylim=(-1, 1))
        ax.set(zlim=(-1, 1))

        ax.set(xticks=[-1, 0, 1])
        ax.set(yticks=[-1, 0, 1])
        ax.set(zticks=[-1, 0, 1])

        plt.legend()

        if show:
            plt.show()

        return fig

    @classmethod
    def animate_rotation(cls, q_data: Union[list, np.array, pd.DataFrame], frames: int = 100, show: bool = True,
                         save: bool = False, path: str = None) -> None:
        """

        :param q_data:
        :param frames:
        :param show:
        :param save:
        :param path:
        :return:
        """

        q_data = cls.to_array(vec=q_data)

        iter_step = int(len(q_data) / frames)

        fig = cls.plot_quaternion(q_data[0], show=False)
        ax = fig.get_axes()[0]
        frame_data = ax.get_children()[: 3]

        anim = animation.FuncAnimation(fig=fig, func=cls._update_frame_data, frames=frames,
                                       fargs=(frame_data, q_data, iter_step, ax), interval=50, blit=False)

        if save or path is not None:
            if path is None:
                path = os.path.dirname(sys.argv[0])

            writer_gif = animation.PillowWriter(fps=60)
            file_path = os.path.join(path, f"Rotation_Anim_{str(time.strftime('%d-%m-%y_%H-%M-%S'))}.gif")
            anim.save(filename=file_path, writer=writer_gif)

        if show:
            plt.show()

    @classmethod
    def _update_frame_data(cls, num: int, frame_data: list, q_data: np.array, iter_step: int, ax: plt.Axes) -> list:
        """

        :param num:
        :param frame_data:
        :param q_data:
        :param iter_step:
        :return:
        """

        q = q_data[num * iter_step]

        p_x = cls.rotate_point(p=[1, 0, 0], q=q, active=True)
        p_y = cls.rotate_point(p=[0, 1, 0], q=q, active=True)
        p_z = cls.rotate_point(p=[0, 0, -1], q=q, active=True)

        for artist in frame_data:
            artist.remove()

        frame_data[0] = ax.quiver(0, 0, 0, p_x[0], p_x[1], p_x[2], length=1, color="r", label="x")
        frame_data[1] = ax.quiver(0, 0, 0, p_y[0], p_y[1], p_y[2], length=1, color="g", label="y")
        frame_data[2] = ax.quiver(0, 0, 0, p_z[0], p_z[1], p_z[2], length=1, color="b", label="z")

        return frame_data
